package starling.rendering
{
   import flash.display3D.Context3D;
   import flash.display3D.Context3DProgramType;
   import flash.display3D.IndexBuffer3D;
   import flash.display3D.VertexBuffer3D;
   import flash.events.Event;
   import flash.geom.Matrix3D;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import starling.core.Starling;
   import starling.errors.MissingContextError;
   import starling.utils.execute;
   
   public class Effect
   {
      
      public static const VERTEX_FORMAT:starling.rendering.VertexDataFormat = starling.rendering.VertexDataFormat.fromString("position:float2");
      
      private static var sProgramNameCache:Dictionary = new Dictionary();
       
      
      private var _vertexBuffer:VertexBuffer3D;
      
      private var _vertexBufferSize:int;
      
      private var _indexBuffer:IndexBuffer3D;
      
      private var _indexBufferSize:int;
      
      private var _indexBufferUsesQuadLayout:Boolean;
      
      private var _mvpMatrix3D:Matrix3D;
      
      private var _onRestore:Function;
      
      private var _programBaseName:String;
      
      public function Effect()
      {
         super();
         this._mvpMatrix3D = new Matrix3D();
         this._programBaseName = getQualifiedClassName(this);
         Starling.current.stage3D.addEventListener(Event.CONTEXT3D_CREATE,this.onContextCreated,false,20,true);
      }
      
      public function dispose() : void
      {
         Starling.current.stage3D.removeEventListener(Event.CONTEXT3D_CREATE,this.onContextCreated);
         this.purgeBuffers();
      }
      
      private function onContextCreated(param1:Event) : void
      {
         this.purgeBuffers();
         execute(this._onRestore,this);
      }
      
      public function purgeBuffers(param1:Boolean = true, param2:Boolean = true) : void
      {
         if(Boolean(this._vertexBuffer) && param1)
         {
            try
            {
               this._vertexBuffer.dispose();
            }
            catch(e:Error)
            {
            }
            this._vertexBuffer = null;
         }
         if(Boolean(this._indexBuffer) && param2)
         {
            try
            {
               this._indexBuffer.dispose();
            }
            catch(e:Error)
            {
            }
            this._indexBuffer = null;
         }
      }
      
      public function uploadIndexData(param1:starling.rendering.IndexData, param2:String = "staticDraw") : void
      {
         var _loc3_:int = param1.numIndices;
         var _loc4_:Boolean = param1.useQuadLayout;
         var _loc5_:Boolean = this._indexBufferUsesQuadLayout;
         if(this._indexBuffer)
         {
            if(_loc3_ <= this._indexBufferSize)
            {
               if(!_loc4_ || !_loc5_)
               {
                  param1.uploadToIndexBuffer(this._indexBuffer);
                  this._indexBufferUsesQuadLayout = _loc4_ && _loc3_ == this._indexBufferSize;
               }
            }
            else
            {
               this.purgeBuffers(false,true);
            }
         }
         if(this._indexBuffer == null)
         {
            this._indexBuffer = param1.createIndexBuffer(true,param2);
            this._indexBufferSize = _loc3_;
            this._indexBufferUsesQuadLayout = _loc4_;
         }
      }
      
      public function uploadVertexData(param1:starling.rendering.VertexData, param2:String = "staticDraw") : void
      {
         if(this._vertexBuffer)
         {
            if(param1.size <= this._vertexBufferSize)
            {
               param1.uploadToVertexBuffer(this._vertexBuffer);
            }
            else
            {
               this.purgeBuffers(true,false);
            }
         }
         if(this._vertexBuffer == null)
         {
            this._vertexBuffer = param1.createVertexBuffer(true,param2);
            this._vertexBufferSize = param1.size;
         }
      }
      
      public function render(param1:int = 0, param2:int = -1) : void
      {
         if(param2 < 0)
         {
            param2 = this._indexBufferSize / 3;
         }
         if(param2 == 0)
         {
            return;
         }
         var _loc3_:Context3D = Starling.context;
         if(_loc3_ == null)
         {
            throw new MissingContextError();
         }
         this.beforeDraw(_loc3_);
         _loc3_.drawTriangles(this.indexBuffer,param1,param2);
         this.afterDraw(_loc3_);
      }
      
      protected function beforeDraw(param1:Context3D) : void
      {
         this.program.activate(param1);
         this.vertexFormat.setVertexBufferAt(0,this.vertexBuffer,"position");
         param1.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,0,this.mvpMatrix3D,true);
      }
      
      protected function afterDraw(param1:Context3D) : void
      {
         param1.setVertexBufferAt(0,null);
      }
      
      protected function createProgram() : starling.rendering.Program
      {
         var _loc1_:String = ["m44 op, va0, vc0","sge v0, va0, va0"].join("\n");
         var _loc2_:String = "mov oc, v0";
         return starling.rendering.Program.fromSource(_loc1_,_loc2_);
      }
      
      protected function get programVariantName() : uint
      {
         return 0;
      }
      
      protected function get programBaseName() : String
      {
         return this._programBaseName;
      }
      
      protected function set programBaseName(param1:String) : void
      {
         this._programBaseName = param1;
      }
      
      protected function get programName() : String
      {
         var _loc1_:String = this.programBaseName;
         var _loc2_:uint = this.programVariantName;
         var _loc3_:Dictionary = sProgramNameCache[_loc1_];
         if(_loc3_ == null)
         {
            _loc3_ = new Dictionary();
            sProgramNameCache[_loc1_] = _loc3_;
         }
         var _loc4_:String;
         if((_loc4_ = String(_loc3_[_loc2_])) == null)
         {
            if(_loc2_)
            {
               _loc4_ = _loc1_ + "#" + _loc2_.toString(16);
            }
            else
            {
               _loc4_ = _loc1_;
            }
            _loc3_[_loc2_] = _loc4_;
         }
         return _loc4_;
      }
      
      protected function get program() : starling.rendering.Program
      {
         var _loc1_:String = this.programName;
         var _loc2_:starling.rendering.Painter = Starling.painter;
         var _loc3_:starling.rendering.Program = _loc2_.getProgram(_loc1_);
         if(_loc3_ == null)
         {
            _loc3_ = this.createProgram();
            _loc2_.registerProgram(_loc1_,_loc3_);
         }
         return _loc3_;
      }
      
      public function get onRestore() : Function
      {
         return this._onRestore;
      }
      
      public function set onRestore(param1:Function) : void
      {
         this._onRestore = param1;
      }
      
      public function get vertexFormat() : starling.rendering.VertexDataFormat
      {
         return VERTEX_FORMAT;
      }
      
      public function get mvpMatrix3D() : Matrix3D
      {
         return this._mvpMatrix3D;
      }
      
      public function set mvpMatrix3D(param1:Matrix3D) : void
      {
         this._mvpMatrix3D.copyFrom(param1);
      }
      
      protected function get indexBuffer() : IndexBuffer3D
      {
         return this._indexBuffer;
      }
      
      protected function get indexBufferSize() : int
      {
         return this._indexBufferSize;
      }
      
      protected function get vertexBuffer() : VertexBuffer3D
      {
         return this._vertexBuffer;
      }
      
      protected function get vertexBufferSize() : int
      {
         return this._vertexBufferSize;
      }
   }
}
