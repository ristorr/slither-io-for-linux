package starling.display.graphics
{
   import flash.display3D.Context3D;
   import flash.display3D.Context3DBlendFactor;
   import flash.display3D.IndexBuffer3D;
   import flash.display3D.VertexBuffer3D;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.core.Starling;
   import starling.display.BlendMode;
   import starling.display.DisplayObject;
   import starling.display.MyBlendMode;
   import starling.display.materials.IMaterial;
   import starling.display.materials.StandardMaterial;
   import starling.display.util.MatrixUtil;
   import starling.errors.AbstractMethodError;
   import starling.errors.MissingContextError;
   import starling.events.Event;
   import starling.rendering.Painter;
   import starling.utils.Pool;
   
   public class GraphicRenderer extends DisplayObject
   {
      
      protected static const VERTEX_STRIDE:int = 9;
      
      protected static var sHelperMatrix:Matrix = new Matrix();
      
      private static var sGraphicHelperRect:flash.geom.Rectangle = new flash.geom.Rectangle();
      
      private static var sGraphicHelperPoint:Point = new Point();
      
      private static var _uintVectorPool:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>();
      
      private static var _numberVectorPool:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
      
      protected static var shapeHitTestPoint:Point = new Point();
      
      protected static var shapeHitTestResultPoint:Point = new Point();
      
      private static var topLeft:Point = new Point();
      
      private static var topRight:Point = new Point();
      
      private static var bottomRight:Point = new Point();
      
      private static var bottomLeft:Point = new Point();
      
      private static var sGraphicHelperPointTR:Point = new Point();
      
      private static var sGraphicHelperPointBL:Point = new Point();
      
      private static var uvPoint:Point = new Point();
      
      private static var transformedPoint:Point = new Point();
      
      private static var i:int;
      
      private static var numVertices:int;
      
      private static var context:Context3D;
      
      private static var blendFactors:Array;
       
      
      protected var _material:IMaterial;
      
      protected var vertexBuffer:VertexBuffer3D;
      
      protected var indexBuffer:IndexBuffer3D;
      
      protected var vertices:Vector.<Number>;
      
      protected var indices:Vector.<uint>;
      
      protected var _uvMatrix:Matrix;
      
      protected var isInvalid:Boolean = false;
      
      protected var uvsInvalid:Boolean = false;
      
      protected var hasValidatedGeometry:Boolean = false;
      
      protected var minBounds:Point;
      
      protected var maxBounds:Point;
      
      protected var _precisionHitTest:Boolean = false;
      
      protected var _precisionHitTestDistance:Number = 0;
      
      protected var _boundsBuffer:Number = 0;
      
      protected var _boundsBufferX:Number = 0;
      
      protected var _boundsBufferY:Number = 0;
      
      private var _boundsBufferDouble:Number = 0;
      
      private var _boundsBufferXDouble:Number = 0;
      
      private var _boundsBufferYDouble:Number = 0;
      
      public function GraphicRenderer()
      {
         super();
         this.indices = getUintVector();
         this.vertices = getNumberVector();
         this._material = new StandardMaterial();
         this.minBounds = Pool.getPoint();
         this.maxBounds = Pool.getPoint();
         if(Starling.current)
         {
            Starling.current.addEventListener(Event.CONTEXT3D_CREATE,this.onContextCreated);
         }
      }
      
      public static function getUintVector() : Vector.<uint>
      {
         var _loc1_:Vector.<uint> = null;
         if(_uintVectorPool.length > 0)
         {
            _loc1_ = _uintVectorPool.pop();
         }
         else
         {
            _loc1_ = new Vector.<uint>();
         }
         return _loc1_;
      }
      
      public static function putUintVector(param1:Vector.<uint>) : void
      {
         if(param1)
         {
            _uintVectorPool[_uintVectorPool.length] = param1;
         }
      }
      
      public static function getNumberVector() : Vector.<Number>
      {
         var _loc1_:Vector.<Number> = null;
         if(_numberVectorPool.length > 0)
         {
            _loc1_ = _numberVectorPool.pop();
         }
         else
         {
            _loc1_ = new Vector.<Number>();
         }
         return _loc1_;
      }
      
      public static function putNumberVector(param1:Vector.<Number>) : void
      {
         if(param1)
         {
            _numberVectorPool[_numberVectorPool.length] = param1;
         }
      }
      
      public function get boundsBuffer() : Number
      {
         return this._boundsBuffer;
      }
      
      public function set boundsBuffer(param1:Number) : void
      {
         this._boundsBuffer = param1;
         this._boundsBufferDouble = param1 * 2;
         this._boundsBufferX = param1;
         this._boundsBufferY = param1;
         this._boundsBufferXDouble = this._boundsBufferDouble;
         this._boundsBufferYDouble = this._boundsBufferDouble;
      }
      
      public function get boundsBufferX() : Number
      {
         return this._boundsBufferX;
      }
      
      public function set boundsBufferX(param1:Number) : void
      {
         this._boundsBufferX = param1;
         this._boundsBufferXDouble = param1 * 2;
      }
      
      public function get boundsBufferY() : Number
      {
         return this._boundsBufferY;
      }
      
      public function set boundsBufferY(param1:Number) : void
      {
         this._boundsBufferY = param1;
         this._boundsBufferYDouble = param1 * 2;
      }
      
      public function set material(param1:IMaterial) : void
      {
         this._material = param1;
      }
      
      public function get material() : IMaterial
      {
         return this._material;
      }
      
      public function get uvMatrix() : Matrix
      {
         return this._uvMatrix;
      }
      
      public function set precisionHitTest(param1:Boolean) : void
      {
         this._precisionHitTest = param1;
      }
      
      public function get precisionHitTest() : Boolean
      {
         return this._precisionHitTest;
      }
      
      public function set precisionHitTestDistance(param1:Number) : void
      {
         this._precisionHitTestDistance = param1;
      }
      
      public function get precisionHitTestDistance() : Number
      {
         return this._precisionHitTestDistance;
      }
      
      public function set uvMatrix(param1:Matrix) : void
      {
         this._uvMatrix = param1;
         this.uvsInvalid = true;
         this.hasValidatedGeometry = false;
      }
      
      private function onContextCreated(param1:Event) : void
      {
         this.hasValidatedGeometry = false;
         this.isInvalid = true;
         this.uvsInvalid = true;
         if(this._material)
         {
            this._material.restoreOnLostContext();
         }
         this.onGraphicLostContext();
      }
      
      protected function onGraphicLostContext() : void
      {
      }
      
      override public function dispose() : void
      {
         if(Starling.current)
         {
            Starling.current.removeEventListener(Event.CONTEXT3D_CREATE,this.onContextCreated);
            super.dispose();
         }
         if(this.vertexBuffer)
         {
            this.vertexBuffer.dispose();
            this.vertexBuffer = null;
         }
         if(this.indexBuffer)
         {
            this.indexBuffer.dispose();
            this.indexBuffer = null;
         }
         if(this._material)
         {
            this.material.dispose();
            this.material = null;
         }
         Pool.putPoint(this.minBounds);
         Pool.putPoint(this.maxBounds);
         if(this.indices)
         {
            this.indices.length = 0;
            putUintVector(this.indices);
            this.indices = null;
         }
         if(this.vertices)
         {
            this.vertices.length = 0;
            putNumberVector(this.vertices);
            this.vertices = null;
         }
         this._uvMatrix = null;
         this.minBounds = null;
         this.maxBounds = null;
         this.hasValidatedGeometry = false;
      }
      
      public function shapeHitTest(param1:Number, param2:Number) : Boolean
      {
         shapeHitTestPoint.x = param1;
         shapeHitTestPoint.y = param2;
         globalToLocal(shapeHitTestPoint,shapeHitTestResultPoint);
         return shapeHitTestResultPoint.x >= this.minBounds.x && shapeHitTestResultPoint.x <= this.maxBounds.x && shapeHitTestResultPoint.y >= this.minBounds.y && shapeHitTestResultPoint.y <= this.maxBounds.y;
      }
      
      protected function shapeHitTestLocalInternal(param1:Number, param2:Number) : Boolean
      {
         return param1 >= this.minBounds.x - this._precisionHitTestDistance && param1 <= this.maxBounds.x + this._precisionHitTestDistance && param2 >= this.minBounds.y - this._precisionHitTestDistance && param2 <= this.maxBounds.y + this._precisionHitTestDistance;
      }
      
      override public function hitTest(param1:Point) : DisplayObject
      {
         if(visible == false || touchable == false)
         {
            return null;
         }
         if(this.minBounds == null || this.maxBounds == null)
         {
            return null;
         }
         if(this.getBounds(this,sGraphicHelperRect).containsPoint(param1))
         {
            if(!this._precisionHitTest)
            {
               return this;
            }
            if(this.shapeHitTestLocalInternal(param1.x,param1.y))
            {
               return this;
            }
         }
         return null;
      }
      
      override public function getBounds(param1:DisplayObject, param2:flash.geom.Rectangle = null) : flash.geom.Rectangle
      {
         if(param2 == null)
         {
            param2 = new flash.geom.Rectangle();
         }
         if(param1 == this)
         {
            param2.x = this.minBounds.x;
            param2.y = this.minBounds.y;
            param2.right = this.maxBounds.x;
            param2.bottom = this.maxBounds.y;
            if(this._precisionHitTest)
            {
               param2.x -= this._precisionHitTestDistance;
               param2.y -= this._precisionHitTestDistance;
               param2.width += this._precisionHitTestDistance * 2;
               param2.height += this._precisionHitTestDistance * 2;
            }
            param2.x -= this._boundsBufferX;
            param2.y -= this._boundsBufferY;
            param2.width += this._boundsBufferXDouble;
            param2.height += this._boundsBufferYDouble;
            param2.right += this._boundsBufferXDouble;
            param2.bottom += this._boundsBufferYDouble;
            return param2;
         }
         getTransformationMatrix(param1,sHelperMatrix);
         sGraphicHelperPointTR.x = this.minBounds.x + (this.maxBounds.x - this.minBounds.x);
         sGraphicHelperPointTR.y = this.minBounds.y;
         sGraphicHelperPointBL.x = this.minBounds.x;
         sGraphicHelperPointBL.y = this.minBounds.y + (this.maxBounds.y - this.minBounds.y);
         MatrixUtil.transformPoint(sHelperMatrix,this.minBounds,topLeft);
         MatrixUtil.transformPoint(sHelperMatrix,sGraphicHelperPointTR,topRight);
         MatrixUtil.transformPoint(sHelperMatrix,this.maxBounds,bottomRight);
         MatrixUtil.transformPoint(sHelperMatrix,sGraphicHelperPointBL,bottomLeft);
         param2.x = Math.min(topLeft.x,bottomRight.x,topRight.x,bottomLeft.x);
         param2.y = Math.min(topLeft.y,bottomRight.y,topRight.y,bottomLeft.y);
         param2.right = Math.max(topLeft.x,bottomRight.x,topRight.x,bottomLeft.x);
         param2.bottom = Math.max(topLeft.y,bottomRight.y,topRight.y,bottomLeft.y);
         if(this._precisionHitTest)
         {
            param2.x -= this._precisionHitTestDistance;
            param2.y -= this._precisionHitTestDistance;
            param2.width += this._precisionHitTestDistance * 2;
            param2.height += this._precisionHitTestDistance * 2;
         }
         param2.x -= this._boundsBufferX;
         param2.y -= this._boundsBufferY;
         param2.width += this._boundsBufferXDouble;
         param2.height += this._boundsBufferYDouble;
         param2.right += this._boundsBufferXDouble;
         param2.bottom += this._boundsBufferYDouble;
         return param2;
      }
      
      protected function buildGeometry() : void
      {
         throw new AbstractMethodError();
      }
      
      protected function applyUVMatrix() : void
      {
         if(!this.vertices)
         {
            return;
         }
         if(!this._uvMatrix)
         {
            return;
         }
         i = 0;
         while(i < this.vertices.length)
         {
            uvPoint.x = this.vertices[i + 7];
            uvPoint.y = this.vertices[i + 8];
            MatrixUtil.transformPoint(this._uvMatrix,uvPoint,transformedPoint);
            if(this._material.texture)
            {
               this._material.texture.localToGlobal(transformedPoint.x,transformedPoint.y,transformedPoint);
            }
            this.vertices[i + 7] = transformedPoint.x;
            this.vertices[i + 8] = transformedPoint.y;
            i += VERTEX_STRIDE;
         }
      }
      
      public function validateNow() : void
      {
         if(this.hasValidatedGeometry)
         {
            return;
         }
         this.hasValidatedGeometry = true;
         if(Boolean(this.vertexBuffer) && (this.isInvalid || this.uvsInvalid))
         {
            this.vertexBuffer.dispose();
            this.indexBuffer.dispose();
         }
         if(this.isInvalid)
         {
            this.buildGeometry();
            this.applyUVMatrix();
         }
         else if(this.uvsInvalid)
         {
            this.applyUVMatrix();
         }
      }
      
      protected function setGeometryInvalid() : void
      {
         this.isInvalid = true;
         this.hasValidatedGeometry = false;
      }
      
      override public function render(param1:Painter) : void
      {
         this.validateNow();
         if(this.indices == null || this.indices.length < 3)
         {
            return;
         }
         context = Starling.context;
         param1.excludeFromCache(this);
         if(this.isInvalid || this.uvsInvalid)
         {
            numVertices = this.vertices.length / VERTEX_STRIDE;
            this.vertexBuffer = context.createVertexBuffer(numVertices,VERTEX_STRIDE);
            this.vertexBuffer.uploadFromVector(this.vertices,0,numVertices);
            this.indexBuffer = context.createIndexBuffer(this.indices.length);
            this.indexBuffer.uploadFromVector(this.indices,0,this.indices.length);
            this.isInvalid = this.uvsInvalid = false;
         }
         param1.finishMeshBatch();
         if(context == null)
         {
            throw new MissingContextError();
         }
         blendFactors = MyBlendMode.getBlendFactors(blendMode == BlendMode.AUTO ? param1.state.blendMode : this.blendMode,true);
         context.setBlendFactors(blendFactors[0],blendFactors[1]);
         this._material.drawTriangles(context,param1.state.mvpMatrix3D,this.vertexBuffer,this.indexBuffer,parent.alpha);
         context.setTextureAt(0,null);
         context.setTextureAt(1,null);
         context.setVertexBufferAt(0,null);
         context.setVertexBufferAt(1,null);
         context.setVertexBufferAt(2,null);
         context.setBlendFactors(Context3DBlendFactor.ONE,Context3DBlendFactor.ZERO);
         context.setBlendFactors(Context3DBlendFactor.ONE,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
      }
   }
}
