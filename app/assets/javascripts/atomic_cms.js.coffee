#= require angular-markdown
#= require showdown.min

# function to find index of a DOM node within its parent
findElementIndex = (node) ->
  i = 0
  while node.previousSibling
    node = node.previousSibling
    if node.nodeType == 1
      i += 1
  i

# function to scroll to an element
scrollTo = (node) ->
  $('html, body').animate({
    scrollTop: $(node).offset().top
  }, 0)

# position edit box
positionEditBox = (node) ->
  minTop = $('#edit-page').offset().top + $('#edit-page').height() + 25;
  top = Math.max(minTop, $(node).offset().top)
  top -= $('#edit-node-column').offset().top;
  $('#edit-node').css(top: top).show()

# create angular module for page editor
page = angular.module 'page', ['markdown', 'ngSanitize']

# filter to construct embedded vimeo path
page.filter 'vimeo_url', ['$sce', ($sce) ->
  (id) ->
    if id.match /^\d+$/
      $sce.trustAsResourceUrl("https://player.vimeo.com/video/#{id}")
]

# parent controller for entire CMS editing hierarchy
page.controller 'CmsCtrl', ['$scope', ($scope) ->
  $scope.prefix = "page[content_object]"
  $scope.preview = {}
]

# wrapper for each Cms::Template descendant
page.directive 'cmsNode', ->
  restrict: 'A'
  scope: true
  controller: ['$scope', '$compile', ($scope, $compile) ->
    $scope.$compile = $compile
    $scope.preview = {}
    # $scope.children = []
    $scope.dragControlListeners =
      itemMoved: (event)->
       alert('moved')
      orderChanged: (event)->
        alert('changed')
  ]
  link: ($scope, element, attrs, controller) ->
    # read prefix for the children of this node from the cms-node attribute
    prefixName = $(element).data("cmsNode")

    # if this node is an array node, prefix it numerically based on its DOM index
    if element.hasClass('cms-array-node')
      prefixName = findElementIndex(element.get(0))

      # on custom 'renumber' event, renumber this array node based on its DOM index
      $scope.$on 'renumber', (event, args) ->
        prefixName = findElementIndex(element.get(0))
        $scope.prefix = "#{$scope.$parent.prefix}[#{prefixName}]"

    # keep child form field name up to date with their position in the CMS hierarchy
    $scope.$parent.$watch 'prefix', (prefix)->
      $scope.prefix = "#{prefix}[#{prefixName}]"

    # if node is an array, define procedures for appending new nodes
    if $(element).hasClass("cms-array")

      # see if this array is the topmost array in the DOM
      topLevelArray = $(element).parent().closest(".cms-array").size() == 0

      # function to append a new child template to this array
      appendNode = (source) ->
        newEl = angular.element(source)
        element.append(newEl)
        $scope.$compile(newEl)($scope)
        $("a", newEl).click (e)->
          e.preventDefault()
        $(newEl).click()

        # only scroll for top level array
        scrollTo(newEl) if topLevelArray

      # catch 'append' broadcasts and append new node to self
      $scope.$on "append", (event, args) ->
        if !event.defaultPrevented
          $.get args.href, (data) ->
            appendNode data
          event.preventDefault()

      # for top level array node, bind top buttons to append new elements
      if topLevelArray
        $("ol.edit-buttons li a.button").unbind("click").bind "click", ->
          $scope.$broadcast "append", href: $(this).attr("href")
          false

    # edit this template node by mirroring the form fields in the sidebar with jQuery
    $scope.edit = ->
      $element = $(element)
      $editor = $('#edit-node-fields')

      # copy span fields into edit sidebar ol/li fields
      $sidebarFields = $("<ol>")
      $sidebarButtons = $("#edit-node fieldset.actions ol")
      $sidebarButtons.find("li.button-field").remove()
      $element.find("> .cms-fields > span.li").each ->
        li = $("<li>").addClass($(this).attr("class")).html($(this).html())
        if li.hasClass("button-field")
          $sidebarButtons.prepend(li)
        else
          $sidebarFields.append(li)
      $editor.empty().append($sidebarFields)

      # bind change events to original fields
      $editor.find(":input").each ->
        $input = $(this)
        fieldName = $input.attr("name").replace($scope.prefix, '').replace(/\[|\]/g, '')
        $input.attr("name", null).val($scope.preview[fieldName])
        $input.on "keyup change", ->
          $scope.$apply ->
            $scope.preview[fieldName] = $input.val()

      # bind 'add' button clicks to append new elements to closest
      $sidebarButtons.find("li.button-field a").unbind("click").click ->
        if $(this).hasClass('emit')
          $scope.$emit "append", href: $(this).attr("href")
        else
          $scope.$broadcast "append", href: $(this).attr("href")
        false

      # mark node as active as a visual cue
      $draft = $('#draft-panel')
      $draft.find('[data-cms-node]').removeClass('active')
      $draft.add(element).addClass('active')

      # set legend title for sidebar
      template = $element.find("> input[name*=template]").val()
      $('#edit-node legend span').html("Edit #{template.replace(/([A-Z]+)/g, ' $1')}")

      # position, show, and focus on edit fields in the sidebar
      positionEditBox($element)
      $editor.find(":input").first().focus()

      # show and bind (or dont) the delete and move buttons
      $delete = $('#edit-node li.delete').hide()
      $move = $('#edit-node li.move').hide()
      parentScope = $scope.$parent
      if element.hasClass('cms-array-node')
        $move.show()
        $delete.show()

        # bind delete button to remove node
        $delete.find('a.button').unbind('click').click ->
          $('#done-edit-node').click()
          element.remove()
          $scope.$destroy()
          parentScope.$broadcast 'renumber'

        # bind 'move up' button to move node to previous position
        domNode = element.get(0)
        $move.find("a#move-node-up").unbind('click').click ->
          if domNode.previousSibling
            domNode.parentNode.insertBefore(domNode, domNode.previousSibling)
            positionEditBox(domNode)
            scrollTo(domNode)
            parentScope.$broadcast 'renumber'
          false

        # bind 'move down' button to move node to next position
        $move.find("a#move-node-down").unbind('click').click ->
          if domNode.nextSibling
            domNode.parentNode.insertBefore(domNode.nextSibling, domNode)
            positionEditBox(domNode)
            scrollTo(domNode)
            parentScope.$broadcast 'renumber'
          false

      false

# field elements for Cms::Template descendant properties
page.directive 'cmsField', ->
  restrict: 'C'
  scope: false
  link: ($scope, element, attrs) ->
    $element = $(element)
    fieldName = $element.attr("name")

    # extract the field value as the default value for the angular scope
    $scope.preview[fieldName] = $element.val()

    # keep form field name up to date with its position in the CMS hierarchy
    $scope.$watch 'prefix', (prefix)->
      $element.attr("name", "#{prefix}[#{fieldName}]")

$(document).ready ->

  # Allow closing the edit box for nodes
  $('#done-edit-node').click ->
    $draft = $('#draft-panel')
    $draft.removeClass('active')
    $draft.find('[data-cms-node]').removeClass('active')
    $('#edit-node').hide()
    false

  $(".preview a").click (e)->
    e.preventDefault()
