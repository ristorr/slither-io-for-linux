package starling.core
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.display.Stage3D;
   import flash.display.StageAlign;
   import flash.display.StageScaleMode;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DProfile;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TouchEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.ui.Mouse;
   import flash.ui.Multitouch;
   import flash.ui.MultitouchInputMode;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import starling.animation.Juggler;
   import starling.display.DisplayObject;
   import starling.display.Stage;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   import starling.events.KeyboardEvent;
   import starling.events.ResizeEvent;
   import starling.events.TouchPhase;
   import starling.events.TouchProcessor;
   import starling.rendering.Painter;
   import starling.utils.Align;
   import starling.utils.Color;
   import starling.utils.MatrixUtil;
   import starling.utils.Pool;
   import starling.utils.RectangleUtil;
   import starling.utils.SystemUtil;
   
   public class Starling extends EventDispatcher
   {
      
      public static const VERSION:String = "2.7";
      
      private static var sCurrent:starling.core.Starling;
      
      private static var sAll:Vector.<starling.core.Starling> = new Vector.<starling.core.Starling>(0);
       
      
      private var _stage:starling.display.Stage;
      
      private var _rootClass:Class;
      
      private var _root:DisplayObject;
      
      private var _juggler:Juggler;
      
      private var _painter:Painter;
      
      private var _touchProcessor:TouchProcessor;
      
      private var _antiAliasing:int;
      
      private var _frameTimestamp:Number;
      
      private var _frameID:uint;
      
      private var _leftMouseDown:Boolean;
      
      private var _statsDisplay:starling.core.StatsDisplay;
      
      private var _statsDisplayAlign:Object;
      
      private var _started:Boolean;
      
      private var _rendering:Boolean;
      
      private var _supportHighResolutions:Boolean;
      
      private var _supportBrowserZoom:Boolean;
      
      private var _skipUnchangedFrames:Boolean;
      
      private var _showStats:Boolean;
      
      private var _supportsCursor:Boolean;
      
      private var _multitouchEnabled:Boolean;
      
      private var _viewPort:flash.geom.Rectangle;
      
      private var _previousViewPort:flash.geom.Rectangle;
      
      private var _clippedViewPort:flash.geom.Rectangle;
      
      private var _nativeStage:flash.display.Stage;
      
      private var _nativeStageEmpty:Boolean;
      
      private var _nativeOverlay:Sprite;
      
      public function Starling(param1:Class, param2:flash.display.Stage, param3:flash.geom.Rectangle = null, param4:Stage3D = null, param5:String = "auto", param6:Object = "auto")
      {
         var _loc8_:String = null;
         super();
         if(param2 == null)
         {
            throw new ArgumentError("Stage must not be null");
         }
         if(param3 == null)
         {
            param3 = new flash.geom.Rectangle(0,0,param2.stageWidth,param2.stageHeight);
         }
         if(param4 == null)
         {
            param4 = param2.stage3Ds[0];
         }
         SystemUtil.initialize();
         sAll.push(this);
         this.makeCurrent();
         this._rootClass = param1;
         this._viewPort = param3;
         this._previousViewPort = new flash.geom.Rectangle();
         this._stage = new starling.display.Stage(param3.width,param3.height,param2.color);
         this._nativeOverlay = new Sprite();
         this._nativeStage = param2;
         this._nativeStage.addChild(this._nativeOverlay);
         this._touchProcessor = new TouchProcessor(this._stage);
         this._touchProcessor.discardSystemGestures = !SystemUtil.isDesktop;
         this._juggler = new Juggler();
         this._antiAliasing = 0;
         this._supportHighResolutions = false;
         this._painter = new Painter(param4);
         this._frameTimestamp = getTimer() / 1000;
         this._frameID = 1;
         this._supportsCursor = Mouse.supportsCursor || Capabilities.os.indexOf("Windows") == 0;
         this._statsDisplayAlign = {};
         this.setMultitouchEnabled(Multitouch.inputMode == MultitouchInputMode.TOUCH_POINT,true);
         this.nativeOverlayBlocksTouches = true;
         param2.scaleMode = StageScaleMode.NO_SCALE;
         param2.align = StageAlign.TOP_LEFT;
         param2.addEventListener(flash.events.Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         param2.addEventListener(flash.events.KeyboardEvent.KEY_DOWN,this.onKey,false,0,true);
         param2.addEventListener(flash.events.KeyboardEvent.KEY_UP,this.onKey,false,0,true);
         param2.addEventListener(flash.events.Event.RESIZE,this.onResize,false,0,true);
         param2.addEventListener(flash.events.Event.MOUSE_LEAVE,this.onMouseLeave,false,0,true);
         param2.addEventListener(flash.events.Event.ACTIVATE,this.onActivate,false,0,true);
         param4.addEventListener(flash.events.Event.CONTEXT3D_CREATE,this.onContextCreated,false,10,true);
         param4.addEventListener(ErrorEvent.ERROR,this.onStage3DError,false,10,true);
         var _loc7_:int;
         if((_loc7_ = parseInt(SystemUtil.version.split(",").shift())) < 19)
         {
            _loc8_ = SystemUtil.isAIR ? "Adobe AIR" : "Flash Player";
            this.stopWithFatalError("Your " + _loc8_ + " installation is outdated. " + "This software requires at least version 19.");
         }
         else if(this._painter.shareContext)
         {
            setTimeout(this.initialize,1);
         }
         else
         {
            this._painter.requestContext3D(param5,param6);
         }
      }
      
      public static function get current() : starling.core.Starling
      {
         return sCurrent;
      }
      
      public static function get all() : Vector.<starling.core.Starling>
      {
         return sAll;
      }
      
      public static function get context() : Context3D
      {
         return !!sCurrent ? sCurrent.context : null;
      }
      
      public static function get juggler() : Juggler
      {
         return !!sCurrent ? sCurrent._juggler : null;
      }
      
      public static function get painter() : Painter
      {
         return !!sCurrent ? sCurrent._painter : null;
      }
      
      public static function get contentScaleFactor() : Number
      {
         return !!sCurrent ? sCurrent.contentScaleFactor : 1;
      }
      
      public static function get multitouchEnabled() : Boolean
      {
         var _loc3_:starling.core.Starling = null;
         var _loc1_:* = Multitouch.inputMode == MultitouchInputMode.TOUCH_POINT;
         var _loc2_:Boolean = false;
         for each(_loc3_ in sAll)
         {
            if(_loc3_._multitouchEnabled != _loc1_)
            {
               _loc2_ = true;
            }
         }
         if(_loc2_)
         {
            trace("[Starling] Warning: multitouch settings are out of sync. Always set " + "\'Starling.multitouchEnabled\' instead of \'Multitouch.inputMode\'.");
         }
         return _loc1_;
      }
      
      public static function set multitouchEnabled(param1:Boolean) : void
      {
         var _loc4_:starling.core.Starling = null;
         var _loc2_:* = Multitouch.inputMode == MultitouchInputMode.TOUCH_POINT;
         Multitouch.inputMode = param1 ? MultitouchInputMode.TOUCH_POINT : MultitouchInputMode.NONE;
         var _loc3_:* = Multitouch.inputMode == MultitouchInputMode.TOUCH_POINT;
         if(_loc2_ != _loc3_)
         {
            for each(_loc4_ in sAll)
            {
               _loc4_.setMultitouchEnabled(_loc3_);
            }
         }
      }
      
      public static function get frameID() : uint
      {
         return !!sCurrent ? sCurrent._frameID : 0;
      }
      
      public function dispose() : void
      {
         var _loc1_:String = null;
         var _loc2_:int = 0;
         this.stop(true);
         this._nativeStage.removeEventListener(flash.events.Event.ENTER_FRAME,this.onEnterFrame,false);
         this._nativeStage.removeEventListener(flash.events.KeyboardEvent.KEY_DOWN,this.onKey,false);
         this._nativeStage.removeEventListener(flash.events.KeyboardEvent.KEY_UP,this.onKey,false);
         this._nativeStage.removeEventListener(flash.events.Event.RESIZE,this.onResize,false);
         this._nativeStage.removeEventListener(flash.events.Event.MOUSE_LEAVE,this.onMouseLeave,false);
         this._nativeStage.removeEventListener(flash.events.Event.BROWSER_ZOOM_CHANGE,this.onBrowserZoomChange,false);
         this._nativeStage.removeChild(this._nativeOverlay);
         this.stage3D.removeEventListener(flash.events.Event.CONTEXT3D_CREATE,this.onContextCreated,false);
         this.stage3D.removeEventListener(flash.events.Event.CONTEXT3D_CREATE,this.onContextRestored,false);
         this.stage3D.removeEventListener(ErrorEvent.ERROR,this.onStage3DError,false);
         for each(_loc1_ in this.getTouchEventTypes(this._multitouchEnabled))
         {
            this._nativeStage.removeEventListener(_loc1_,this.onTouch,false);
         }
         this._touchProcessor.dispose();
         this._stage.dispose();
         this._painter.dispose();
         _loc2_ = sAll.indexOf(this);
         if(_loc2_ != -1)
         {
            sAll.removeAt(_loc2_);
         }
         if(sCurrent == this)
         {
            sCurrent = null;
         }
      }
      
      private function initialize() : void
      {
         this.makeCurrent();
         this.updateViewPort(true);
         dispatchEventWith(flash.events.Event.CONTEXT3D_CREATE,false,this.context);
         this.initializeRoot();
         this._frameTimestamp = getTimer() / 1000;
      }
      
      private function initializeRoot() : void
      {
         if(this._root == null && this._rootClass != null)
         {
            this._root = new this._rootClass() as DisplayObject;
            if(this._root == null)
            {
               throw new Error("Invalid root class: " + this._rootClass);
            }
            this._stage.addChildAt(this._root,0);
            dispatchEventWith(starling.events.Event.ROOT_CREATED,false,this._root);
         }
      }
      
      public function nextFrame() : void
      {
         var _loc1_:Number = getTimer() / 1000;
         var _loc2_:Number = _loc1_ - this._frameTimestamp;
         this._frameTimestamp = _loc1_;
         if(_loc2_ > 1)
         {
            _loc2_ = 1;
         }
         if(_loc2_ < 0)
         {
            _loc2_ = 1 / this._nativeStage.frameRate;
         }
         this.advanceTime(_loc2_);
         this.render();
      }
      
      public function advanceTime(param1:Number) : void
      {
         if(!this.contextValid)
         {
            return;
         }
         this.makeCurrent();
         this._touchProcessor.advanceTime(param1);
         this._stage.advanceTime(param1);
         this._juggler.advanceTime(param1);
      }
      
      public function render() : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:uint = 0;
         if(!this.contextValid)
         {
            return;
         }
         this.makeCurrent();
         this.updateViewPort();
         var _loc1_:Boolean = this._stage.requiresRedraw || this.mustAlwaysRender;
         if(_loc1_)
         {
            dispatchEventWith(starling.events.Event.RENDER);
            _loc2_ = this._painter.shareContext;
            _loc3_ = this._viewPort.width / this._stage.stageWidth;
            _loc4_ = this._viewPort.height / this._stage.stageHeight;
            _loc5_ = this._stage.color;
            this._painter.nextFrame();
            this._painter.pixelSize = 1 / this.contentScaleFactor;
            this._painter.state.setProjectionMatrix(this._viewPort.x < 0 ? -this._viewPort.x / _loc3_ : 0,this._viewPort.y < 0 ? -this._viewPort.y / _loc4_ : 0,this._clippedViewPort.width / _loc3_,this._clippedViewPort.height / _loc4_,this._stage.stageWidth,this._stage.stageHeight,this._stage.cameraPosition);
            if(!_loc2_)
            {
               this._painter.clear(_loc5_,Color.getAlpha(_loc5_));
            }
            this._stage.render(this._painter);
            this._painter.finishFrame();
            this._painter.frameID = ++this._frameID;
            if(!_loc2_)
            {
               this._painter.present();
            }
         }
         else
         {
            dispatchEventWith(starling.events.Event.SKIP_FRAME);
         }
         if(this._statsDisplay)
         {
            this._statsDisplay.drawCount = this._painter.drawCount;
         }
      }
      
      private function updateViewPort(param1:Boolean = false) : void
      {
         var _loc2_:Number = NaN;
         if(param1 || !RectangleUtil.compare(this._viewPort,this._previousViewPort))
         {
            this._previousViewPort.setTo(this._viewPort.x,this._viewPort.y,this._viewPort.width,this._viewPort.height);
            this.updateClippedViewPort();
            this.updateStatsDisplayPosition();
            _loc2_ = this._supportHighResolutions ? this._nativeStage.contentsScaleFactor : 1;
            if(this._supportBrowserZoom)
            {
               _loc2_ *= this._nativeStage.browserZoomFactor;
            }
            this._painter.configureBackBuffer(this._clippedViewPort,_loc2_,this._antiAliasing,true,this._supportBrowserZoom);
            this.setRequiresRedraw();
         }
      }
      
      private function updateClippedViewPort() : void
      {
         var _loc1_:flash.geom.Rectangle = Pool.getRectangle(0,0,this._nativeStage.stageWidth,this._nativeStage.stageHeight);
         this._clippedViewPort = RectangleUtil.intersect(this._viewPort,_loc1_,this._clippedViewPort);
         if(this._clippedViewPort.width < 32)
         {
            this._clippedViewPort.width = 32;
         }
         if(this._clippedViewPort.height < 32)
         {
            this._clippedViewPort.height = 32;
         }
         Pool.putRectangle(_loc1_);
      }
      
      private function updateNativeOverlay() : void
      {
         this._nativeOverlay.x = this._viewPort.x;
         this._nativeOverlay.y = this._viewPort.y;
         this._nativeOverlay.scaleX = this._viewPort.width / this._stage.stageWidth;
         this._nativeOverlay.scaleY = this._viewPort.height / this._stage.stageHeight;
      }
      
      public function stopWithFatalError(param1:String) : void
      {
         var _loc2_:Shape = new Shape();
         _loc2_.graphics.beginFill(0,0.8);
         _loc2_.graphics.drawRect(0,0,this._stage.stageWidth,this._stage.stageHeight);
         _loc2_.graphics.endFill();
         var _loc3_:TextField = new TextField();
         var _loc4_:TextFormat;
         (_loc4_ = new TextFormat("Verdana",14,16777215)).align = TextFormatAlign.CENTER;
         _loc3_.defaultTextFormat = _loc4_;
         _loc3_.wordWrap = true;
         _loc3_.width = this._stage.stageWidth * 0.75;
         _loc3_.autoSize = TextFieldAutoSize.CENTER;
         _loc3_.text = param1;
         _loc3_.x = (this._stage.stageWidth - _loc3_.width) / 2;
         _loc3_.y = (this._stage.stageHeight - _loc3_.height) / 2;
         _loc3_.background = true;
         _loc3_.backgroundColor = 5570560;
         this.updateNativeOverlay();
         this.nativeOverlay.addChild(_loc2_);
         this.nativeOverlay.addChild(_loc3_);
         this.stop(true);
         trace("[Starling]",param1);
         dispatchEventWith(starling.events.Event.FATAL_ERROR,false,param1);
      }
      
      public function makeCurrent() : void
      {
         sCurrent = this;
      }
      
      public function start() : void
      {
         this._started = this._rendering = true;
         this._frameTimestamp = getTimer() / 1000;
      }
      
      public function stop(param1:Boolean = false) : void
      {
         this._started = false;
         this._rendering = !param1;
      }
      
      public function setRequiresRedraw() : void
      {
         this._stage.setRequiresRedraw();
      }
      
      private function onStage3DError(param1:ErrorEvent) : void
      {
         var _loc2_:String = null;
         if(param1.errorID == 3702)
         {
            _loc2_ = Capabilities.playerType == "Desktop" ? "renderMode" : "wmode";
            this.stopWithFatalError("Context3D not available! Possible reasons: wrong " + _loc2_ + " or missing device support.");
         }
         else
         {
            this.stopWithFatalError("Stage3D error: " + param1.text);
         }
      }
      
      private function onContextCreated(param1:flash.events.Event) : void
      {
         this.stage3D.removeEventListener(flash.events.Event.CONTEXT3D_CREATE,this.onContextCreated);
         this.stage3D.addEventListener(flash.events.Event.CONTEXT3D_CREATE,this.onContextRestored,false,10,true);
         trace("[Starling] Context ready. Display Driver:",this.context.driverInfo);
         this.initialize();
      }
      
      private function onContextRestored(param1:flash.events.Event) : void
      {
         trace("[Starling] Context restored.");
         this.updateViewPort(true);
         this._painter.setupContextDefaults();
         dispatchEventWith(flash.events.Event.CONTEXT3D_CREATE,false,this.context);
      }
      
      private function onEnterFrame(param1:flash.events.Event) : void
      {
         if(!this.shareContext)
         {
            if(this._started)
            {
               this.nextFrame();
            }
            else if(this._rendering)
            {
               this.render();
            }
         }
         this.updateNativeOverlay();
      }
      
      private function onActivate(param1:flash.events.Event) : void
      {
         setTimeout(this.setRequiresRedraw,100);
      }
      
      private function onKey(param1:flash.events.KeyboardEvent) : void
      {
         if(!this._started)
         {
            return;
         }
         var _loc2_:starling.events.KeyboardEvent = new starling.events.KeyboardEvent(param1.type,param1.charCode,param1.keyCode,param1.keyLocation,param1.ctrlKey,param1.altKey,param1.shiftKey);
         this.makeCurrent();
         this._stage.dispatchEvent(_loc2_);
         if(_loc2_.isDefaultPrevented())
         {
            param1.preventDefault();
         }
      }
      
      private function onResize(param1:flash.events.Event) : void
      {
         var stageWidth:int = 0;
         var stageHeight:int = 0;
         var dispatchResizeEvent:Function = null;
         var event:flash.events.Event = param1;
         dispatchResizeEvent = function():void
         {
            makeCurrent();
            removeEventListener(flash.events.Event.CONTEXT3D_CREATE,dispatchResizeEvent);
            _stage.dispatchEvent(new ResizeEvent(flash.events.Event.RESIZE,stageWidth,stageHeight));
         };
         stageWidth = int(event.target.stageWidth);
         stageHeight = int(event.target.stageHeight);
         if(this.contextValid)
         {
            dispatchResizeEvent();
         }
         else
         {
            addEventListener(flash.events.Event.CONTEXT3D_CREATE,dispatchResizeEvent);
         }
      }
      
      private function onBrowserZoomChange(param1:flash.events.Event) : void
      {
         this._painter.refreshBackBufferSize(this._nativeStage.contentsScaleFactor * this._nativeStage.browserZoomFactor);
      }
      
      private function onMouseLeave(param1:flash.events.Event) : void
      {
         this._touchProcessor.enqueueMouseLeftStage();
      }
      
      private function onTouch(param1:flash.events.Event) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc9_:MouseEvent = null;
         var _loc10_:TouchEvent = null;
         if(!this._started)
         {
            return;
         }
         var _loc6_:Number = 1;
         var _loc7_:Number = 1;
         var _loc8_:Number = 1;
         if(param1 is MouseEvent)
         {
            _loc2_ = (_loc9_ = param1 as MouseEvent).stageX;
            _loc3_ = _loc9_.stageY;
            _loc4_ = 0;
            if(param1.type == MouseEvent.MOUSE_DOWN)
            {
               this._leftMouseDown = true;
            }
            else if(param1.type == MouseEvent.MOUSE_UP)
            {
               this._leftMouseDown = false;
            }
         }
         else
         {
            _loc10_ = param1 as TouchEvent;
            if(this._supportsCursor && _loc10_.isPrimaryTouchPoint)
            {
               return;
            }
            _loc2_ = _loc10_.stageX;
            _loc3_ = _loc10_.stageY;
            _loc4_ = _loc10_.touchPointID;
            _loc6_ = _loc10_.pressure;
            _loc7_ = _loc10_.sizeX;
            _loc8_ = _loc10_.sizeY;
         }
         switch(param1.type)
         {
            case TouchEvent.TOUCH_BEGIN:
               _loc5_ = TouchPhase.BEGAN;
               break;
            case TouchEvent.TOUCH_MOVE:
               _loc5_ = TouchPhase.MOVED;
               break;
            case TouchEvent.TOUCH_END:
               _loc5_ = TouchPhase.ENDED;
               break;
            case MouseEvent.MOUSE_DOWN:
               _loc5_ = TouchPhase.BEGAN;
               break;
            case MouseEvent.MOUSE_UP:
               _loc5_ = TouchPhase.ENDED;
               break;
            case MouseEvent.MOUSE_MOVE:
               _loc5_ = this._leftMouseDown ? TouchPhase.MOVED : TouchPhase.HOVER;
         }
         _loc2_ = this._stage.stageWidth * (_loc2_ - this._viewPort.x) / this._viewPort.width;
         _loc3_ = this._stage.stageHeight * (_loc3_ - this._viewPort.y) / this._viewPort.height;
         this._touchProcessor.enqueue(_loc4_,_loc5_,_loc2_,_loc3_,_loc6_,_loc7_,_loc8_);
         if(param1.type == MouseEvent.MOUSE_UP && this._supportsCursor)
         {
            this._touchProcessor.enqueue(_loc4_,TouchPhase.HOVER,_loc2_,_loc3_);
         }
      }
      
      private function hitTestNativeOverlay(param1:Number, param2:Number) : Boolean
      {
         var _loc3_:Point = null;
         var _loc4_:Matrix = null;
         var _loc5_:Boolean = false;
         if(this._nativeOverlay.numChildren)
         {
            _loc3_ = Pool.getPoint();
            _loc4_ = Pool.getMatrix(this._nativeOverlay.scaleX,0,0,this._nativeOverlay.scaleY,this._nativeOverlay.x,this._nativeOverlay.y);
            MatrixUtil.transformCoords(_loc4_,param1,param2,_loc3_);
            _loc5_ = this._nativeOverlay.hitTestPoint(_loc3_.x,_loc3_.y,true);
            Pool.putPoint(_loc3_);
            Pool.putMatrix(_loc4_);
            return _loc5_;
         }
         return false;
      }
      
      private function setMultitouchEnabled(param1:Boolean, param2:Boolean = false) : void
      {
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         if(param2 || param1 != this._multitouchEnabled)
         {
            _loc3_ = this.getTouchEventTypes(this._multitouchEnabled);
            _loc4_ = this.getTouchEventTypes(param1);
            for each(_loc5_ in _loc3_)
            {
               this._nativeStage.removeEventListener(_loc5_,this.onTouch);
            }
            for each(_loc6_ in _loc4_)
            {
               this._nativeStage.addEventListener(_loc6_,this.onTouch,false,0,true);
            }
            this._touchProcessor.cancelTouches();
            this._multitouchEnabled = param1;
         }
      }
      
      private function getTouchEventTypes(param1:Boolean) : Array
      {
         var _loc2_:Array = [];
         if(param1)
         {
            _loc2_.push(TouchEvent.TOUCH_BEGIN,TouchEvent.TOUCH_MOVE,TouchEvent.TOUCH_END);
         }
         if(!param1 || this._supportsCursor)
         {
            _loc2_.push(MouseEvent.MOUSE_DOWN,MouseEvent.MOUSE_MOVE,MouseEvent.MOUSE_UP);
         }
         return _loc2_;
      }
      
      private function get mustAlwaysRender() : Boolean
      {
         var _loc1_:Boolean = false;
         var _loc2_:Boolean = false;
         if(!this._skipUnchangedFrames || this._painter.shareContext)
         {
            return true;
         }
         if(SystemUtil.isDesktop && this.profile != Context3DProfile.BASELINE_CONSTRAINED)
         {
            return false;
         }
         _loc1_ = Boolean(isNativeDisplayObjectEmpty(this._nativeStage));
         _loc2_ = !_loc1_ || !this._nativeStageEmpty;
         this._nativeStageEmpty = _loc1_;
         return _loc2_;
      }
      
      public function get isStarted() : Boolean
      {
         return this._started;
      }
      
      public function get juggler() : Juggler
      {
         return this._juggler;
      }
      
      public function get painter() : Painter
      {
         return this._painter;
      }
      
      public function get context() : Context3D
      {
         return this._painter.context;
      }
      
      public function get simulateMultitouch() : Boolean
      {
         return this._touchProcessor.simulateMultitouch;
      }
      
      public function set simulateMultitouch(param1:Boolean) : void
      {
         this._touchProcessor.simulateMultitouch = param1;
      }
      
      public function get enableErrorChecking() : Boolean
      {
         return this._painter.enableErrorChecking;
      }
      
      public function set enableErrorChecking(param1:Boolean) : void
      {
         this._painter.enableErrorChecking = param1;
      }
      
      public function get antiAliasing() : int
      {
         return this._antiAliasing;
      }
      
      public function set antiAliasing(param1:int) : void
      {
         if(this._antiAliasing != param1)
         {
            this._antiAliasing = param1;
            if(this.contextValid)
            {
               this.updateViewPort(true);
            }
         }
      }
      
      public function get viewPort() : flash.geom.Rectangle
      {
         return this._viewPort;
      }
      
      public function set viewPort(param1:flash.geom.Rectangle) : void
      {
         this._viewPort.copyFrom(param1);
      }
      
      public function get contentScaleFactor() : Number
      {
         return this._viewPort.width * this._painter.backBufferScaleFactor / this._stage.stageWidth;
      }
      
      public function get nativeOverlay() : Sprite
      {
         return this._nativeOverlay;
      }
      
      public function get nativeOverlayBlocksTouches() : Boolean
      {
         return this._touchProcessor.occlusionTest != null;
      }
      
      public function set nativeOverlayBlocksTouches(param1:Boolean) : void
      {
         if(param1 != this.nativeOverlayBlocksTouches)
         {
            this._touchProcessor.occlusionTest = param1 ? this.hitTestNativeOverlay : null;
         }
      }
      
      public function get showStats() : Boolean
      {
         return this._showStats;
      }
      
      public function set showStats(param1:Boolean) : void
      {
         this._showStats = param1;
         if(param1)
         {
            this.showStatsAt(String(this._statsDisplayAlign.horizontal) || "left",String(this._statsDisplayAlign.vertical) || "top");
         }
         else if(this._statsDisplay)
         {
            this._statsDisplay.removeFromParent();
         }
      }
      
      public function showStatsAt(param1:String = "left", param2:String = "top", param3:Number = 1) : void
      {
         var onRootCreated:Function = null;
         var horizontalAlign:String = param1;
         var verticalAlign:String = param2;
         var scale:Number = param3;
         onRootCreated = function():void
         {
            if(_showStats)
            {
               showStatsAt(horizontalAlign,verticalAlign,scale);
            }
            removeEventListener(starling.events.Event.ROOT_CREATED,onRootCreated);
         };
         this._showStats = true;
         this._statsDisplayAlign.horizontal = horizontalAlign;
         this._statsDisplayAlign.vertical = verticalAlign;
         if(this.context == null)
         {
            addEventListener(starling.events.Event.ROOT_CREATED,onRootCreated);
         }
         else
         {
            if(this._statsDisplay == null)
            {
               this._statsDisplay = new starling.core.StatsDisplay();
               this._statsDisplay.touchable = false;
            }
            this._stage.addChild(this._statsDisplay);
            this._statsDisplay.scaleX = this._statsDisplay.scaleY = scale;
            this._statsDisplay.showSkipped = this._skipUnchangedFrames;
            this.updateClippedViewPort();
            this.updateStatsDisplayPosition();
         }
      }
      
      private function updateStatsDisplayPosition() : void
      {
         if(!this._showStats || this._statsDisplay == null)
         {
            return;
         }
         var _loc1_:String = String(this._statsDisplayAlign.horizontal);
         var _loc2_:String = String(this._statsDisplayAlign.vertical);
         var _loc3_:Number = this._viewPort.width / this._stage.stageWidth;
         var _loc4_:Number = this._viewPort.height / this._stage.stageHeight;
         var _loc5_:flash.geom.Rectangle = Pool.getRectangle(this._viewPort.x < 0 ? -this._viewPort.x / _loc3_ : 0,this._viewPort.y < 0 ? -this._viewPort.y / _loc4_ : 0,this._clippedViewPort.width / _loc3_,this._clippedViewPort.height / _loc4_);
         if(_loc1_ == Align.LEFT)
         {
            this._statsDisplay.x = _loc5_.x;
         }
         else if(_loc1_ == Align.RIGHT)
         {
            this._statsDisplay.x = _loc5_.right - this._statsDisplay.width;
         }
         else
         {
            if(_loc1_ != Align.CENTER)
            {
               throw new ArgumentError("Invalid horizontal alignment: " + _loc1_);
            }
            this._statsDisplay.x = (_loc5_.right - this._statsDisplay.width) / 2;
         }
         if(_loc2_ == Align.TOP)
         {
            this._statsDisplay.y = _loc5_.y;
         }
         else if(_loc2_ == Align.BOTTOM)
         {
            this._statsDisplay.y = _loc5_.bottom - this._statsDisplay.height;
         }
         else
         {
            if(_loc2_ != Align.CENTER)
            {
               throw new ArgumentError("Invalid vertical alignment: " + _loc2_);
            }
            this._statsDisplay.y = (_loc5_.bottom - this._statsDisplay.height) / 2;
         }
         Pool.putRectangle(_loc5_);
      }
      
      public function get stage() : starling.display.Stage
      {
         return this._stage;
      }
      
      public function get stage3D() : Stage3D
      {
         return this._painter.stage3D;
      }
      
      public function get nativeStage() : flash.display.Stage
      {
         return this._nativeStage;
      }
      
      public function get root() : DisplayObject
      {
         return this._root;
      }
      
      public function get rootClass() : Class
      {
         return this._rootClass;
      }
      
      public function set rootClass(param1:Class) : void
      {
         if(this._rootClass != null && this._root != null)
         {
            throw new Error("Root class may not change after root has been instantiated");
         }
         if(this._rootClass == null)
         {
            this._rootClass = param1;
            if(this.context)
            {
               this.initializeRoot();
            }
         }
      }
      
      public function get shareContext() : Boolean
      {
         return this._painter.shareContext;
      }
      
      public function set shareContext(param1:Boolean) : void
      {
         if(!param1)
         {
            this._previousViewPort.setEmpty();
         }
         this._painter.shareContext = param1;
      }
      
      public function get profile() : String
      {
         return this._painter.profile;
      }
      
      public function get supportHighResolutions() : Boolean
      {
         return this._supportHighResolutions;
      }
      
      public function set supportHighResolutions(param1:Boolean) : void
      {
         if(this._supportHighResolutions != param1)
         {
            this._supportHighResolutions = param1;
            if(this.contextValid)
            {
               this.updateViewPort(true);
            }
         }
      }
      
      public function get supportBrowserZoom() : Boolean
      {
         return this._supportBrowserZoom;
      }
      
      public function set supportBrowserZoom(param1:Boolean) : void
      {
         if(this._supportBrowserZoom != param1)
         {
            this._supportBrowserZoom = param1;
            if(this.contextValid)
            {
               this.updateViewPort(true);
            }
            if(param1)
            {
               this._nativeStage.addEventListener(flash.events.Event.BROWSER_ZOOM_CHANGE,this.onBrowserZoomChange,false,0,true);
            }
            else
            {
               this._nativeStage.removeEventListener(flash.events.Event.BROWSER_ZOOM_CHANGE,this.onBrowserZoomChange,false);
            }
         }
      }
      
      public function get skipUnchangedFrames() : Boolean
      {
         return this._skipUnchangedFrames;
      }
      
      public function set skipUnchangedFrames(param1:Boolean) : void
      {
         this._skipUnchangedFrames = param1;
         this._nativeStageEmpty = false;
         if(this._statsDisplay)
         {
            this._statsDisplay.showSkipped = param1;
         }
      }
      
      public function get touchProcessor() : TouchProcessor
      {
         return this._touchProcessor;
      }
      
      public function set touchProcessor(param1:TouchProcessor) : void
      {
         if(param1 == null)
         {
            throw new ArgumentError("TouchProcessor must not be null");
         }
         if(param1 != this._touchProcessor)
         {
            this._touchProcessor.dispose();
            this._touchProcessor = param1;
         }
      }
      
      public function get discardSystemGestures() : Boolean
      {
         return this._touchProcessor.discardSystemGestures;
      }
      
      public function set discardSystemGestures(param1:Boolean) : void
      {
         this._touchProcessor.discardSystemGestures = param1;
      }
      
      public function get frameID() : uint
      {
         return this._frameID;
      }
      
      public function get contextValid() : Boolean
      {
         return this._painter.contextValid;
      }
   }
}

function isNativeDisplayObjectEmpty(param1:DisplayObject):Boolean
{
   var _loc2_:DisplayObjectContainer = null;
   var _loc3_:int = 0;
   var _loc4_:int = 0;
   if(param1 == null)
   {
      return true;
   }
   if(param1 is DisplayObjectContainer)
   {
      _loc2_ = param1 as DisplayObjectContainer;
      _loc3_ = _loc2_.numChildren;
      _loc4_ = 0;
      while(_loc4_ < _loc3_)
      {
         if(!isNativeDisplayObjectEmpty(_loc2_.getChildAt(_loc4_)))
         {
            return false;
         }
         _loc4_++;
      }
      return true;
   }
   return !param1.visible;
}