//= require angular-markdown
//= require showdown.min

(function() {
  'use strict';
  var findElementIndex, page, positionEditBox, scrollTo, cmsType;

  findElementIndex = function(node) {
    var i = 0;
    while (node.previousSibling) {
      node = node.previousSibling;
      if (node.nodeType === 1) {
        i += 1;
      }
    }
    return i;
  };

  scrollTo = function(node) {
    return $('html, body').animate({
      scrollTop: $(node).offset().top
    }, 0);
  };

  positionEditBox = function(node) {
    var minTop, top;
    minTop = $('#edit-' + cmsType()).offset().top + $('#edit-' + cmsType()).height() + 25;
    top = Math.max(minTop, $(node).offset().top);
    top -= $('#edit-node-column').offset().top;
    return $('#edit-node').css({
      top: top
    }).show();
  };

  cmsType = function(node) {
    var cms_type = angular.element(document.querySelector('#cms_type')).val();
    return (cms_type !== undefined) ? cms_type : 'page';
  };

  page = angular.module('page', ['markdown', 'ngSanitize']);

  page.filter('vimeo_url', [
    '$sce', function($sce) {
      return function(id) {
        if (id.match(/^\d+$/)) {
          return $sce.trustAsResourceUrl('https://player.vimeo.com/video/' + id);
        }
      };
    }
  ]);

  page.controller('CmsCtrl', [
    '$scope', function($scope) {
      $scope.prefix = cmsType() + '[content_object]';
      return $scope.preview = {};
    }
  ]);

  page.directive('cmsNode', function() {
    return {
      restrict: 'A',
      scope: true,
      controller: [
        '$scope', '$compile', function($scope, $compile) {
          $scope.$compile = $compile;
          $scope.preview = {};
          return $scope.dragControlListeners = {
            itemMoved: function(event) {
              return alert('moved');
            },
            orderChanged: function(event) {
              return alert('changed');
            }
          };
        }
      ],
      link: function($scope, element, attrs, controller) {
        var appendNode, prefixName, topLevelArray;
        prefixName = $(element).data('cmsNode');
        if (element.hasClass('cms-array-node')) {
          prefixName = findElementIndex(element.get(0));
          $scope.$on('renumber', function(event, args) {
            prefixName = findElementIndex(element.get(0));
            return $scope.prefix = $scope.$parent.prefix + '[' + prefixName + ']';
          });
        }
        $scope.$parent.$watch('prefix', function(prefix) {
          return $scope.prefix = prefix + '[' + prefixName + ']';
        });
        if ($(element).hasClass('cms-array')) {
          topLevelArray = $(element).parent().closest('.cms-array').size() === 0;
          appendNode = function(source) {
            var newEl;
            newEl = angular.element(source);
            element.append(newEl);
            $scope.$compile(newEl)($scope);
            $('a', newEl).click(function(e) {
              return e.preventDefault();
            });
            $(newEl).click();
            if (topLevelArray) {
              return scrollTo(newEl);
            }
          };
          $scope.$on('append', function(event, args) {
            if (!event.defaultPrevented) {
              $.get(args.href, function(data) {
                return appendNode(data);
              });
              return event.preventDefault();
            }
          });
          if (topLevelArray) {
            $('ol.edit-buttons li a.button').unbind('click').bind('click', function() {
              $scope.$broadcast('append', {
                href: $(this).attr('href')
              });
              return false;
            });
          }
        }
        return $scope.edit = function() {
          var $delete, $draft, $editor, $element, $move, $sidebarButtons, $sidebarFields, domNode, parentScope, template;
          $element = $(element);
          $editor = $('#edit-node-fields');
          $sidebarFields = $('<ol>');
          $sidebarButtons = $('#edit-node fieldset.actions ol');
          $sidebarButtons.find('li.button-field').remove();
          $element.find('> .cms-fields > span.li').each(function() {
            var li;
            li = $('<li>').addClass($(this).attr('class')).html($(this).html());
            if (li.hasClass('button-field')) {
              return $sidebarButtons.prepend(li);
            } else {
              return $sidebarFields.append(li);
            }
          });

          $editor.empty().append($sidebarFields);

          $editor.find(':file').each(function() {
            var $input = $(this);
            var $next = $($input.siblings('input'));
            $input.attr('name', null).val('');

            return $input.on('change', function() {

              var formData = new FormData(),
                  fileData = event.target.files[0],
                  next = $(event.target).next();
                  formData.append('file', fileData);

              $.ajax({
                url: '/atomic_cms/media',
                type: 'POST',
                dataType: 'text',
                data: formData,
                contentType: false,
                processData: false,
                success: function (data) {
                  var parsed = JSON.parse(data);
                  $next.val(parsed.url);
                  $next.change();
                }
              });
            });
          });

          $editor.find(':input').each(function() {
            if($(this).prop('type') === 'file') return;//guard clause, already processed file fields

            var $input = $(this);
            var fieldName = $input.attr('name').replace($scope.prefix, '').replace(/\[|\]/g, '');

            $input.attr('name', null).val($scope.preview[fieldName]);

            return $input.on('keyup change', function() {
              $scope.$apply(function() {
                $scope.preview[fieldName] = $input.val();
              });
            });
          });

          $sidebarButtons.find('li.button-field a').unbind('click').click(function() {
            if ($(this).hasClass('emit')) {
              $scope.$emit('append', {
                href: $(this).attr('href')
              });
            } else {
              $scope.$broadcast('append', {
                href: $(this).attr('href')
              });
            }
            return false;
          });
          $draft = $('#draft-panel');
          $draft.find('[data-cms-node]').removeClass('active');
          $draft.add(element).addClass('active');
          template = $element.find('> input[name*=template]').val();
          $('#edit-node legend span').html('Edit ' + (template.replace(/([A-Z]+)/g, ' $1')));
          positionEditBox($element);
          $editor.find(':input').first().focus();
          $delete = $('#edit-node li.delete').hide();
          $move = $('#edit-node li.move').hide();
          parentScope = $scope.$parent;
          if (element.hasClass('cms-array-node')) {
            $move.show();
            $delete.show();
            $delete.find('a.button').unbind('click').click(function() {
              $('#done-edit-node').click();
              element.remove();
              $scope.$destroy();
              return parentScope.$broadcast('renumber');
            });
            domNode = element.get(0);
            $move.find('a#move-node-up').unbind('click').click(function() {
              if (domNode.previousSibling) {
                domNode.parentNode.insertBefore(domNode, domNode.previousSibling);
                positionEditBox(domNode);
                scrollTo(domNode);
                parentScope.$broadcast('renumber');
              }
              return false;
            });
            $move.find('a#move-node-down').unbind('click').click(function() {
              if (domNode.nextSibling) {
                domNode.parentNode.insertBefore(domNode.nextSibling, domNode);
                positionEditBox(domNode);
                scrollTo(domNode);
                parentScope.$broadcast('renumber');
              }
              return false;
            });
          }
          return false;
        };
      }
    };
  });

  page.directive('cmsField', function() {
    return {
      restrict: 'C',
      scope: false,
      link: function($scope, element, attrs) {
        var $element, fieldName;
        $element = $(element);
        fieldName = $element.attr('name');
        $scope.preview[fieldName] = $element.val();
        return $scope.$watch('prefix', function(prefix) {
          return $element.attr('name', prefix + '[' + fieldName + ']');
        });
      }
    };
  });

  $(document).ready(function() {
    $('#done-edit-node').click(function() {
      var $draft = $('#draft-panel');

      $draft.removeClass('active');
      $draft.find('[data-cms-node]').removeClass('active');

      $('#edit-node').hide();
      return false;
    });
    return $('.preview a').click(function(e) {
      return e.preventDefault();
    });
  });

}).call(this);
