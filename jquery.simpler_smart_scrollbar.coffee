(($) -> 
  CustomScroller =
    $customScrollBox: null
    $customScrollBox_container: null
    $customScrollBox_content: null
    $dragger_container: null
    $dragger: null
    animSpeed: null
    easeType: null
    bottomSpace: null
    mouse_wheel_support: null

    init: ($container, animSpeed, easeType, bottomSpace, mouse_wheel_support) ->
      CustomScroller.animSpeed            = animSpeed
      CustomScroller.easeType             = easeType
      CustomScroller.bottomSpace          = bottomSpace
      CustomScroller.mouse_wheel_support  = mouse_wheel_support
      # set data attributes
      CustomScroller.$customScrollBox.data "minDraggerHeight", CustomScroller.$dragger.height()  unless CustomScroller.$customScrollBox.data("minDraggerHeight")
      CustomScroller.$customScrollBox.data "minDraggerWidth", CustomScroller.$dragger.width()  unless CustomScroller.$customScrollBox.data("minDraggerWidth")
      CustomScroller.$customScrollBox.data "contentHeight", CustomScroller.$customScrollBox_container.height()  unless CustomScroller.$customScrollBox.data("contentHeight")
      CustomScroller.$customScrollBox.data "contentWidth", CustomScroller.$customScrollBox_container.width()  unless CustomScroller.$customScrollBox.data("contentWidth")
      
      # jist of it
      CustomScroller.draggerMouseUpAndDown()
      if CustomScroller.$customScrollBox_container.height() > CustomScroller.visibleHeight()
        CustomScroller.initCssBlocks()
        CustomScroller.adjustDraggerHeight()
        CustomScroller.initDraggable()
        CustomScroller.initScrollByClickingInEmptyScrollArea()
        CustomScroller.mouseWheelSupport(CustomScroller.mouse_wheel_support)
      else
        CustomScroller.initCssWhenNoScrollerNeeded()
    
    draggerMouseUpAndDown: ->
      CustomScroller.$dragger.mouseup(->
        CustomScroller.draggerRelease()
      ).mousedown ->
        CustomScroller.draggerPress()

    visibleHeight: ->
      CustomScroller.$customScrollBox.height()

    totalContent: ->
      CustomScroller.$customScrollBox_content.height()

    draggerContainerHeight: ->
      CustomScroller.$dragger_container.height()

    minDraggerHeight: ->
      CustomScroller.$customScrollBox.data("minDraggerHeight")

    draggerPress: ->
      CustomScroller.$dragger.addClass "dragger_pressed"

    draggerRelease: ->
      CustomScroller.$dragger.removeClass "dragger_pressed"

    draggerHeight: ->
      CustomScroller.$dragger.height()

    adjustDraggerHeight: ->
      md_height   = CustomScroller.minDraggerHeight()
      dc_height   = CustomScroller.draggerContainerHeight()
      adjustment  = Math.round(CustomScroller.totalContent() - ((CustomScroller.totalContent() - CustomScroller.visibleHeight()) * 1.3))

      if adjustment <= md_height
        CustomScroller.$dragger.css("height", md_height + "px").css "line-height", md_height + "px"
      else if adjustment >= dc_height
        CustomScroller.$dragger.css("height", dc_height - 10 + "px").css "line-height", dc_height - 10 + "px"
      else
        CustomScroller.$dragger.css("height", adjustment + "px").css "line-height", adjustment + "px"

    scroll: ->
      targY         = 0
      CustomScroller.bottomSpace   = 1 if CustomScroller.bottomSpace < 1 # no bottom space should ever be less than 1
      scrollAmount  = (CustomScroller.totalContent() - (CustomScroller.visibleHeight() / CustomScroller.bottomSpace)) / (CustomScroller.draggerContainerHeight() - CustomScroller.draggerHeight())
      
      animSpeed = CustomScroller.animSpeed
      easeType  = CustomScroller.easeType
      
      draggerY = CustomScroller.$dragger.position().top
      targY = -draggerY * scrollAmount
      
      thePos = CustomScroller.$customScrollBox_container.position().top - targY
      CustomScroller.$customScrollBox_container.stop().animate top: "-=" + thePos, animSpeed, easeType

    scrollTo: (targY) ->
      if targY
        max_targY = CustomScroller.visibleHeight() - CustomScroller.totalContent()
        targY = max_targY if targY < max_targY
        
        CustomScroller.bottomSpace   = 1 if CustomScroller.bottomSpace < 1 # no bottom space should ever be less than 1
        scrollAmount  = (CustomScroller.totalContent() - (CustomScroller.visibleHeight() / CustomScroller.bottomSpace)) / (CustomScroller.draggerContainerHeight() - CustomScroller.draggerHeight())
        
        animSpeed = CustomScroller.animSpeed
        easeType  = CustomScroller.easeType
        
        thePos = CustomScroller.$customScrollBox_container.position().top - targY
        draggerY = - (targY / scrollAmount)
        CustomScroller.$customScrollBox_container.stop().animate top: "-=" + thePos, animSpeed, easeType
        CustomScroller.$dragger.stop().animate top: draggerY, animSpeed, easeType
      
    initDraggable: ->
      CustomScroller.$dragger.draggable 
        axis: "y"
        containment: "parent"
        drag: (event, ui) ->
          CustomScroller.scroll()
        stop: (event, ui) ->
          CustomScroller.draggerRelease()

    initCssBlocks: ->
      CustomScroller.$dragger.css "display", "block"
      CustomScroller.$dragger_container.css "display", "block"

    initCssWhenNoScrollerNeeded: ->
      CustomScroller.$dragger.css("top", 0).css "display", "none"
      CustomScroller.$customScrollBox_container.css "top", 0
      CustomScroller.$dragger_container.css "display", "none"

    initScrollByClickingInEmptyScrollArea: ->
      CustomScroller.$dragger_container.click (e) ->
        $this = $(this)
        mouseCoord = (e.pageY - $this.offset().top)
        if mouseCoord < CustomScroller.$dragger.position().top or mouseCoord > (CustomScroller.$dragger.position().top + CustomScroller.$dragger.height())
          targetPos = mouseCoord + CustomScroller.$dragger.height()
          if targetPos < CustomScroller.$dragger_container.height()
            CustomScroller.$dragger.css "top", mouseCoord
            CustomScroller.scroll()
          else
            CustomScroller.$dragger.css "top", CustomScroller.$dragger_container.height() - CustomScroller.$dragger.height()
            CustomScroller.scroll()

    mouseWheelSupport: (mouse_wheel_support) ->
      $ ($) ->
        if mouse_wheel_support == "yes"
          CustomScroller.$customScrollBox.unbind "mousewheel"
          CustomScroller.$customScrollBox.bind "mousewheel", (event, delta) ->
            vel = Math.abs(delta * 10)
            CustomScroller.$dragger.css "top", CustomScroller.$dragger.position().top - (delta * vel)
            CustomScroller.scroll()
            if CustomScroller.$dragger.position().top < 0
              CustomScroller.$dragger.css "top", 0
              CustomScroller.$customScrollBox_container.stop()
              CustomScroller.scroll()
            if CustomScroller.$dragger.position().top > CustomScroller.$dragger_container.height() - CustomScroller.$dragger.height()
              CustomScroller.$dragger.css "top", CustomScroller.$dragger_container.height() - CustomScroller.$dragger.height()
              CustomScroller.$customScrollBox_container.stop()
              CustomScroller.scroll()
            false
  
  $.fn.simple_smart_scrollbar = (animSpeed=400, easeType="easeOutCirc", bottomSpace=1, mouse_wheel_support="yes") ->
    $container                        = $(this)
    CustomScroller.$customScrollBox                  = $container.find(".customScrollBox")
    CustomScroller.$customScrollBox_container        = $container.find(".customScrollBox .container")
    CustomScroller.$customScrollBox_content          = $container.find(".customScrollBox .content")
    CustomScroller.$dragger_container                = $container.find(".dragger_container")
    CustomScroller.$dragger                          = $container.find(".dragger")
    
    CustomScroller.init($(this), animSpeed, easeType, bottomSpace, mouse_wheel_support)
    
    

  
  $.fn.simple_smart_scrollbar.scrollTo = (targY) ->
    CustomScroller.scrollTo(targY)
       
) jQuery