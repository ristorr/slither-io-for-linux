package starling.rendering
{
   import flash.display.Stage3D;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DCompareMode;
   import flash.display3D.Context3DStencilAction;
   import flash.display3D.Context3DTriangleFace;
   import flash.display3D.textures.TextureBase;
   import flash.errors.IllegalOperationError;
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import starling.core.starling_internal;
   import starling.display.BlendMode;
   import starling.display.DisplayObject;
   import starling.display.Mesh;
   import starling.display.MeshBatch;
   import starling.display.Quad;
   import starling.events.Event;
   import starling.textures.Texture;
   import starling.utils.MathUtil;
   import starling.utils.MatrixUtil;
   import starling.utils.MeshSubset;
   import starling.utils.Pool;
   import starling.utils.RectangleUtil;
   import starling.utils.RenderUtil;
   import starling.utils.SystemUtil;
   
   public class Painter
   {
      
      private static const PROGRAM_DATA_NAME:String = "starling.rendering.Painter.Programs";
      
      public static const DEFAULT_STENCIL_VALUE:uint = 127;
      
      private static var sSharedData:Dictionary = new Dictionary();
      
      private static var sMatrix:Matrix = new Matrix();
      
      private static var sPoint3D:Vector3D = new Vector3D();
      
      private static var sMatrix3D:Matrix3D = new Matrix3D();
      
      private static var sClipRect:flash.geom.Rectangle = new flash.geom.Rectangle();
      
      private static var sBufferRect:flash.geom.Rectangle = new flash.geom.Rectangle();
      
      private static var sScissorRect:flash.geom.Rectangle = new flash.geom.Rectangle();
      
      private static var sMeshSubset:MeshSubset = new MeshSubset();
       
      
      private var _stage3D:Stage3D;
      
      private var _context:Context3D;
      
      private var _shareContext:Boolean;
      
      private var _drawCount:int;
      
      private var _frameID:uint;
      
      private var _pixelSize:Number;
      
      private var _enableErrorChecking:Boolean;
      
      private var _stencilReferenceValues:Dictionary;
      
      private var _clipRectStack:Vector.<flash.geom.Rectangle>;
      
      private var _batchCacheExclusions:Vector.<DisplayObject>;
      
      private var _batchTrimInterval:int = 250;
      
      private var _batchProcessor:starling.rendering.BatchProcessor;
      
      private var _batchProcessorCurr:starling.rendering.BatchProcessor;
      
      private var _batchProcessorPrev:starling.rendering.BatchProcessor;
      
      private var _batchProcessorSpec:starling.rendering.BatchProcessor;
      
      private var _actualRenderTarget:TextureBase;
      
      private var _actualRenderTargetOptions:uint;
      
      private var _actualCulling:String;
      
      private var _actualBlendMode:String;
      
      private var _actualDepthMask:Boolean;
      
      private var _actualDepthTest:String;
      
      private var _backBufferWidth:Number;
      
      private var _backBufferHeight:Number;
      
      private var _backBufferScaleFactor:Number;
      
      private var _state:starling.rendering.RenderState;
      
      private var _stateStack:Vector.<starling.rendering.RenderState>;
      
      private var _stateStackPos:int;
      
      private var _stateStackLength:int;
      
      public function Painter(param1:Stage3D)
      {
         super();
         this._stage3D = param1;
         this._stage3D.addEventListener(Event.CONTEXT3D_CREATE,this.onContextCreated,false,40,true);
         this._context = this._stage3D.context3D;
         this._shareContext = Boolean(this._context) && this._context.driverInfo != "Disposed";
         this._backBufferWidth = !!this._context ? this._context.backBufferWidth : 0;
         this._backBufferHeight = !!this._context ? this._context.backBufferHeight : 0;
         this._backBufferScaleFactor = this._pixelSize = 1;
         this._stencilReferenceValues = new Dictionary(true);
         this._clipRectStack = new Vector.<flash.geom.Rectangle>(0);
         this._batchProcessorCurr = new starling.rendering.BatchProcessor();
         this._batchProcessorCurr.onBatchComplete = this.drawBatch;
         this._batchProcessorPrev = new starling.rendering.BatchProcessor();
         this._batchProcessorPrev.onBatchComplete = this.drawBatch;
         this._batchProcessorSpec = new starling.rendering.BatchProcessor();
         this._batchProcessorSpec.onBatchComplete = this.drawBatch;
         this._batchProcessor = this._batchProcessorCurr;
         this._batchCacheExclusions = new Vector.<DisplayObject>();
         this._state = new starling.rendering.RenderState();
         this._state.onDrawRequired = this.finishMeshBatch;
         this._stateStack = new Vector.<starling.rendering.RenderState>(0);
         this._stateStackPos = -1;
         this._stateStackLength = 0;
      }
      
      public function dispose() : void
      {
         this._batchProcessorCurr.dispose();
         this._batchProcessorPrev.dispose();
         this._batchProcessorSpec.dispose();
         if(!this._shareContext)
         {
            if(this._context)
            {
               this._context.dispose(false);
            }
            sSharedData = new Dictionary();
         }
      }
      
      public function requestContext3D(param1:String, param2:*) : void
      {
         RenderUtil.requestContext3D(this._stage3D,param1,param2);
      }
      
      private function onContextCreated(param1:Object) : void
      {
         this._context = this._stage3D.context3D;
         this._context.enableErrorChecking = this._enableErrorChecking;
      }
      
      public function configureBackBuffer(param1:flash.geom.Rectangle, param2:Number, param3:int, param4:Boolean, param5:Boolean = false) : void
      {
         if(!this._shareContext)
         {
            param4 &&= SystemUtil.supportsDepthAndStencil;
            if(this._context.profile == "baselineConstrained")
            {
               this._context.configureBackBuffer(32,32,param3,param4);
            }
            if(param1.width * param2 > this._context.maxBackBufferWidth || param1.height * param2 > this._context.maxBackBufferHeight)
            {
               param2 = 1;
            }
            this._stage3D.x = param1.x;
            this._stage3D.y = param1.y;
            this._context.configureBackBuffer(param1.width,param1.height,param3,param4,param2 != 1,param5);
         }
         this._backBufferWidth = param1.width;
         this._backBufferHeight = param1.height;
         this._backBufferScaleFactor = param2;
      }
      
      public function registerProgram(param1:String, param2:starling.rendering.Program) : void
      {
         this.deleteProgram(param1);
         this.programs[param1] = param2;
      }
      
      public function deleteProgram(param1:String) : void
      {
         var _loc2_:starling.rendering.Program = this.getProgram(param1);
         if(_loc2_)
         {
            _loc2_.dispose();
            delete this.programs[param1];
         }
      }
      
      public function getProgram(param1:String) : starling.rendering.Program
      {
         return this.programs[param1] as starling.rendering.Program;
      }
      
      public function hasProgram(param1:String) : Boolean
      {
         return param1 in this.programs;
      }
      
      public function pushState(param1:starling.rendering.BatchToken = null) : void
      {
         ++this._stateStackPos;
         if(this._stateStackLength < this._stateStackPos + 1)
         {
            var _loc2_:* = this._stateStackLength++;
            this._stateStack[_loc2_] = new starling.rendering.RenderState();
         }
         if(param1)
         {
            this._batchProcessor.fillToken(param1);
         }
         this._stateStack[this._stateStackPos].copyFrom(this._state);
      }
      
      public function setStateTo(param1:Matrix, param2:Number = 1, param3:String = "auto") : void
      {
         if(param1)
         {
            MatrixUtil.prependMatrix(this._state._modelviewMatrix,param1);
         }
         if(param2 != 1)
         {
            this._state._alpha *= param2;
         }
         if(param3 != BlendMode.AUTO)
         {
            this._state.blendMode = param3;
         }
      }
      
      public function popState(param1:starling.rendering.BatchToken = null) : void
      {
         if(this._stateStackPos < 0)
         {
            throw new IllegalOperationError("Cannot pop empty state stack");
         }
         this._state.copyFrom(this._stateStack[this._stateStackPos]);
         --this._stateStackPos;
         if(param1)
         {
            this._batchProcessor.fillToken(param1);
         }
      }
      
      public function restoreState() : void
      {
         if(this._stateStackPos < 0)
         {
            throw new IllegalOperationError("Cannot restore from empty state stack");
         }
         this._state.copyFrom(this._stateStack[this._stateStackPos]);
      }
      
      public function fillToken(param1:starling.rendering.BatchToken) : void
      {
         if(param1)
         {
            this._batchProcessor.fillToken(param1);
         }
      }
      
      public function drawMask(param1:DisplayObject, param2:DisplayObject = null) : void
      {
         if(this._context == null)
         {
            return;
         }
         this.finishMeshBatch();
         if(this.isRectangularMask(param1,param2,sMatrix))
         {
            param1.getBounds(param1,sClipRect);
            RectangleUtil.getBounds(sClipRect,sMatrix,sClipRect);
            this.pushClipRect(sClipRect);
         }
         else
         {
            if(Boolean(param2) && param2.maskInverted)
            {
               this._context.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK,Context3DCompareMode.ALWAYS,Context3DStencilAction.DECREMENT_SATURATE);
               this.renderMask(param1);
            }
            else
            {
               this._context.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK,Context3DCompareMode.EQUAL,Context3DStencilAction.INCREMENT_SATURATE);
               this.renderMask(param1);
               ++this.stencilReferenceValue;
            }
            this._context.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK,Context3DCompareMode.EQUAL);
         }
         this.excludeFromCache(param2);
      }
      
      public function eraseMask(param1:DisplayObject, param2:DisplayObject = null) : void
      {
         if(this._context == null)
         {
            return;
         }
         this.finishMeshBatch();
         if(this.isRectangularMask(param1,param2,sMatrix))
         {
            this.popClipRect();
         }
         else
         {
            if(Boolean(param2) && param2.maskInverted)
            {
               this._context.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK,Context3DCompareMode.ALWAYS,Context3DStencilAction.INCREMENT_SATURATE);
               this.renderMask(param1);
            }
            else
            {
               this._context.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK,Context3DCompareMode.EQUAL,Context3DStencilAction.DECREMENT_SATURATE);
               this.renderMask(param1);
               --this.stencilReferenceValue;
            }
            this._context.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK,Context3DCompareMode.EQUAL);
         }
      }
      
      private function renderMask(param1:DisplayObject) : void
      {
         var _loc2_:Matrix = null;
         var _loc3_:Matrix3D = null;
         var _loc4_:Boolean = this.cacheEnabled;
         this.pushState();
         this.cacheEnabled = false;
         this._state.alpha = 0;
         if(param1.stage)
         {
            this._state.setModelviewMatricesToIdentity();
            if(param1.is3D)
            {
               _loc3_ = param1.getTransformationMatrix3D(null,sMatrix3D);
            }
            else
            {
               _loc2_ = param1.getTransformationMatrix(null,sMatrix);
            }
         }
         else if(param1.is3D)
         {
            _loc3_ = param1.transformationMatrix3D;
         }
         else
         {
            _loc2_ = param1.transformationMatrix;
         }
         if(_loc3_)
         {
            this._state.transformModelviewMatrix3D(_loc3_);
         }
         else
         {
            this._state.transformModelviewMatrix(_loc2_);
         }
         param1.render(this);
         this.finishMeshBatch();
         this.cacheEnabled = _loc4_;
         this.popState();
      }
      
      private function pushClipRect(param1:flash.geom.Rectangle) : void
      {
         var _loc2_:Vector.<flash.geom.Rectangle> = this._clipRectStack;
         var _loc3_:uint = _loc2_.length;
         var _loc4_:flash.geom.Rectangle = Pool.getRectangle();
         if(_loc3_)
         {
            RectangleUtil.intersect(_loc2_[_loc3_ - 1],param1,_loc4_);
         }
         else
         {
            _loc4_.copyFrom(param1);
         }
         _loc2_[_loc3_] = _loc4_;
         this._state.clipRect = _loc4_;
      }
      
      private function popClipRect() : void
      {
         var _loc1_:Vector.<flash.geom.Rectangle> = this._clipRectStack;
         var _loc2_:uint = _loc1_.length;
         if(_loc2_ == 0)
         {
            throw new Error("Trying to pop from empty clip rectangle stack");
         }
         _loc2_--;
         Pool.putRectangle(_loc1_.pop());
         this._state.clipRect = !!_loc2_ ? _loc1_[_loc2_ - 1] : null;
      }
      
      private function isRectangularMask(param1:DisplayObject, param2:DisplayObject, param3:Matrix) : Boolean
      {
         var _loc4_:Quad = param1 as Quad;
         var _loc5_:Boolean = Boolean(param2) && param2.maskInverted;
         var _loc6_:Boolean = param1.is3D || param2 && param2.is3D && param1.stage == null;
         if(_loc4_ && !_loc5_ && !_loc6_ && _loc4_.texture == null)
         {
            if(param1.stage)
            {
               param1.getTransformationMatrix(null,param3);
            }
            else
            {
               param3.copyFrom(param1.transformationMatrix);
               param3.concat(this._state.modelviewMatrix);
            }
            return MathUtil.isEquivalent(param3.a,0) && MathUtil.isEquivalent(param3.d,0) || MathUtil.isEquivalent(param3.b,0) && MathUtil.isEquivalent(param3.c,0);
         }
         return false;
      }
      
      public function batchMesh(param1:Mesh, param2:MeshSubset = null) : void
      {
         this._batchProcessor.addMesh(param1,this._state,param2);
      }
      
      public function finishMeshBatch() : void
      {
         this._batchProcessor.finishBatch();
      }
      
      public function enableBatchTrimming(param1:Boolean = true, param2:int = 250) : void
      {
         this._batchTrimInterval = param1 ? param2 : 0;
      }
      
      public function finishFrame() : void
      {
         var _loc1_:* = 0;
         var _loc2_:int = 0;
         if(this._batchTrimInterval > 0)
         {
            _loc1_ = this._batchTrimInterval | 1;
            _loc2_ = this._batchTrimInterval * 1.5;
            if(this._frameID % _loc1_ == 0)
            {
               this._batchProcessorCurr.trim();
            }
            if(this._frameID % _loc2_ == 0)
            {
               this._batchProcessorSpec.trim();
            }
         }
         this._batchProcessor.finishBatch();
         this._batchProcessor = this._batchProcessorSpec;
         this.processCacheExclusions();
      }
      
      private function processCacheExclusions() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = int(this._batchCacheExclusions.length);
         _loc1_ = 0;
         while(_loc1_ < _loc2_)
         {
            this._batchCacheExclusions[_loc1_].starling_internal::excludeFromCache();
            _loc1_++;
         }
         this._batchCacheExclusions.length = 0;
      }
      
      public function setupContextDefaults() : void
      {
         this._actualBlendMode = null;
         this._actualCulling = null;
         this._actualDepthMask = false;
         this._actualDepthTest = null;
      }
      
      public function nextFrame() : void
      {
         this._batchProcessor = this.swapBatchProcessors();
         this._batchProcessor.clear();
         this._batchProcessorSpec.clear();
         this.setupContextDefaults();
         this.stencilReferenceValue = DEFAULT_STENCIL_VALUE;
         this._clipRectStack.length = 0;
         this._drawCount = 0;
         this._stateStackPos = -1;
         this._state.reset();
      }
      
      private function swapBatchProcessors() : starling.rendering.BatchProcessor
      {
         var _loc1_:starling.rendering.BatchProcessor = this._batchProcessorPrev;
         this._batchProcessorPrev = this._batchProcessorCurr;
         return this._batchProcessorCurr = _loc1_;
      }
      
      public function drawFromCache(param1:starling.rendering.BatchToken, param2:starling.rendering.BatchToken) : void
      {
         var _loc3_:MeshBatch = null;
         var _loc5_:int = 0;
         var _loc4_:MeshSubset = sMeshSubset;
         if(!param1.equals(param2))
         {
            this.pushState();
            _loc5_ = param1.batchID;
            while(_loc5_ <= param2.batchID)
            {
               _loc3_ = this._batchProcessorPrev.getBatchAt(_loc5_);
               _loc4_.setTo();
               if(_loc5_ == param1.batchID)
               {
                  _loc4_.vertexID = param1.vertexID;
                  _loc4_.indexID = param1.indexID;
                  _loc4_.numVertices = _loc3_.numVertices - _loc4_.vertexID;
                  _loc4_.numIndices = _loc3_.numIndices - _loc4_.indexID;
               }
               if(_loc5_ == param2.batchID)
               {
                  _loc4_.numVertices = param2.vertexID - _loc4_.vertexID;
                  _loc4_.numIndices = param2.indexID - _loc4_.indexID;
               }
               if(_loc4_.numVertices)
               {
                  this._state.alpha = 1;
                  this._state.blendMode = _loc3_.blendMode;
                  this._batchProcessor.addMesh(_loc3_,this._state,_loc4_,true);
               }
               _loc5_++;
            }
            this.popState();
         }
      }
      
      public function excludeFromCache(param1:DisplayObject) : void
      {
         if(param1)
         {
            this._batchCacheExclusions[this._batchCacheExclusions.length] = param1;
         }
      }
      
      private function drawBatch(param1:MeshBatch) : void
      {
         this.pushState();
         this.state.blendMode = param1.blendMode;
         this.state.modelviewMatrix.identity();
         this.state.alpha = 1;
         param1.render(this);
         this.popState();
      }
      
      public function prepareToDraw() : void
      {
         this.applyBlendMode();
         this.applyRenderTarget();
         this.applyClipRect();
         this.applyCulling();
         this.applyDepthTest();
      }
      
      public function clear(param1:uint = 0, param2:Number = 0) : void
      {
         this.applyRenderTarget();
         this.stencilReferenceValue = DEFAULT_STENCIL_VALUE;
         RenderUtil.clear(param1,param2,1,DEFAULT_STENCIL_VALUE);
      }
      
      public function present() : void
      {
         this._state.renderTarget = null;
         this._actualRenderTarget = null;
         this._context.present();
      }
      
      private function applyBlendMode() : void
      {
         var _loc1_:String = this._state.blendMode;
         if(_loc1_ != this._actualBlendMode)
         {
            BlendMode.get(this._state.blendMode).activate();
            this._actualBlendMode = _loc1_;
         }
      }
      
      private function applyCulling() : void
      {
         var _loc1_:String = this._state.culling;
         if(_loc1_ != this._actualCulling)
         {
            this._context.setCulling(_loc1_);
            this._actualCulling = _loc1_;
         }
      }
      
      private function applyDepthTest() : void
      {
         var _loc1_:Boolean = this._state.depthMask;
         var _loc2_:String = this._state.depthTest;
         if(_loc1_ != this._actualDepthMask || _loc2_ != this._actualDepthTest)
         {
            this._context.setDepthTest(_loc1_,_loc2_);
            this._actualDepthMask = _loc1_;
            this._actualDepthTest = _loc2_;
         }
      }
      
      private function applyRenderTarget() : void
      {
         var _loc3_:int = 0;
         var _loc4_:Boolean = false;
         var _loc1_:TextureBase = this._state.renderTargetBase;
         var _loc2_:uint = this._state.renderTargetOptions;
         if(_loc1_ != this._actualRenderTarget || _loc2_ != this._actualRenderTargetOptions)
         {
            if(_loc1_)
            {
               _loc3_ = this._state.renderTargetAntiAlias;
               _loc4_ = this._state.renderTargetSupportsDepthAndStencil;
               this._context.setRenderToTexture(_loc1_,_loc4_,_loc3_);
            }
            else
            {
               this._context.setRenderToBackBuffer();
            }
            this._context.setStencilReferenceValue(this.stencilReferenceValue);
            this._actualRenderTargetOptions = _loc2_;
            this._actualRenderTarget = _loc1_;
         }
      }
      
      private function applyClipRect() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Matrix3D = null;
         var _loc5_:Texture = null;
         var _loc1_:flash.geom.Rectangle = this._state.clipRect;
         if(_loc1_)
         {
            _loc4_ = this._state.projectionMatrix3D;
            if(_loc5_ = this._state.renderTarget)
            {
               _loc2_ = _loc5_.root.nativeWidth;
               _loc3_ = _loc5_.root.nativeHeight;
            }
            else
            {
               _loc2_ = this._backBufferWidth;
               _loc3_ = this._backBufferHeight;
            }
            MatrixUtil.transformCoords3D(_loc4_,_loc1_.x,_loc1_.y,0,sPoint3D);
            sPoint3D.project();
            sClipRect.x = (sPoint3D.x * 0.5 + 0.5) * _loc2_;
            sClipRect.y = (0.5 - sPoint3D.y * 0.5) * _loc3_;
            MatrixUtil.transformCoords3D(_loc4_,_loc1_.right,_loc1_.bottom,0,sPoint3D);
            sPoint3D.project();
            sClipRect.right = (sPoint3D.x * 0.5 + 0.5) * _loc2_;
            sClipRect.bottom = (0.5 - sPoint3D.y * 0.5) * _loc3_;
            sBufferRect.setTo(0,0,_loc2_,_loc3_);
            RectangleUtil.intersect(sClipRect,sBufferRect,sScissorRect);
            if(sScissorRect.width < 1 || sScissorRect.height < 1)
            {
               sScissorRect.setTo(0,0,1,1);
            }
            this._context.setScissorRectangle(sScissorRect);
         }
         else
         {
            this._context.setScissorRectangle(null);
         }
      }
      
      public function refreshBackBufferSize(param1:Number) : void
      {
         this._backBufferWidth = this._context.backBufferWidth;
         this._backBufferHeight = this._context.backBufferHeight;
         this._backBufferScaleFactor = param1;
      }
      
      public function get drawCount() : int
      {
         return this._drawCount;
      }
      
      public function set drawCount(param1:int) : void
      {
         this._drawCount = param1;
      }
      
      public function get stencilReferenceValue() : uint
      {
         var _loc1_:Object = !!this._state.renderTarget ? this._state.renderTargetBase : this;
         if(_loc1_ in this._stencilReferenceValues)
         {
            return this._stencilReferenceValues[_loc1_];
         }
         return DEFAULT_STENCIL_VALUE;
      }
      
      public function set stencilReferenceValue(param1:uint) : void
      {
         var _loc2_:Object = !!this._state.renderTarget ? this._state.renderTargetBase : this;
         this._stencilReferenceValues[_loc2_] = param1;
         if(this.contextValid)
         {
            this._context.setStencilReferenceValue(param1);
         }
      }
      
      public function get cacheEnabled() : Boolean
      {
         return this._batchProcessor == this._batchProcessorCurr;
      }
      
      public function set cacheEnabled(param1:Boolean) : void
      {
         if(param1 != this.cacheEnabled)
         {
            this.finishMeshBatch();
            if(param1)
            {
               this._batchProcessor = this._batchProcessorCurr;
            }
            else
            {
               this._batchProcessor = this._batchProcessorSpec;
            }
         }
      }
      
      public function get state() : starling.rendering.RenderState
      {
         return this._state;
      }
      
      public function get stage3D() : Stage3D
      {
         return this._stage3D;
      }
      
      public function get context() : Context3D
      {
         return this._context;
      }
      
      public function set frameID(param1:uint) : void
      {
         this._frameID = param1;
      }
      
      public function get frameID() : uint
      {
         return this._batchProcessor == this._batchProcessorCurr ? this._frameID : 0;
      }
      
      public function get pixelSize() : Number
      {
         return this._pixelSize;
      }
      
      public function set pixelSize(param1:Number) : void
      {
         this._pixelSize = param1;
      }
      
      public function get shareContext() : Boolean
      {
         return this._shareContext;
      }
      
      public function set shareContext(param1:Boolean) : void
      {
         this._shareContext = param1;
      }
      
      public function get enableErrorChecking() : Boolean
      {
         return this._enableErrorChecking;
      }
      
      public function set enableErrorChecking(param1:Boolean) : void
      {
         this._enableErrorChecking = param1;
         if(this._context)
         {
            this._context.enableErrorChecking = param1;
         }
         if(param1)
         {
            trace("[Starling] Warning: \'enableErrorChecking\' has a " + "negative impact on performance. Never activate for release builds!");
         }
      }
      
      public function get backBufferWidth() : int
      {
         return this._backBufferWidth;
      }
      
      public function get backBufferHeight() : int
      {
         return this._backBufferHeight;
      }
      
      public function get backBufferScaleFactor() : Number
      {
         return this._backBufferScaleFactor;
      }
      
      public function get contextValid() : Boolean
      {
         var _loc1_:String = null;
         if(this._context)
         {
            _loc1_ = this._context.driverInfo;
            return _loc1_ != null && _loc1_ != "" && _loc1_ != "Disposed";
         }
         return false;
      }
      
      public function get profile() : String
      {
         if(this._context)
         {
            return this._context.profile;
         }
         return null;
      }
      
      public function get sharedData() : Dictionary
      {
         var _loc1_:Dictionary = sSharedData[this.stage3D] as Dictionary;
         if(_loc1_ == null)
         {
            _loc1_ = new Dictionary();
            sSharedData[this.stage3D] = _loc1_;
         }
         return _loc1_;
      }
      
      private function get programs() : Dictionary
      {
         var _loc1_:Dictionary = this.sharedData[PROGRAM_DATA_NAME] as Dictionary;
         if(_loc1_ == null)
         {
            _loc1_ = new Dictionary();
            this.sharedData[PROGRAM_DATA_NAME] = _loc1_;
         }
         return _loc1_;
      }
   }
}
