package starling.rendering
{
   import flash.display3D.Context3D;
   import flash.display3D.Context3DProgramType;
   import flash.utils.getQualifiedClassName;
   
   public class MeshEffect extends starling.rendering.FilterEffect
   {
      
      public static const VERTEX_FORMAT:starling.rendering.VertexDataFormat = starling.rendering.FilterEffect.VERTEX_FORMAT.extend("color:bytes4");
      
      private static var sRenderAlpha:Vector.<Number> = new Vector.<Number>(4,true);
       
      
      private var _alpha:Number;
      
      private var _tinted:Boolean;
      
      private var _optimizeIfNotTinted:Boolean;
      
      public function MeshEffect()
      {
         super();
         this._alpha = 1;
         this._optimizeIfNotTinted = getQualifiedClassName(this) == "starling.rendering::MeshEffect";
      }
      
      override protected function get programVariantName() : uint
      {
         var _loc1_:uint = uint(this._optimizeIfNotTinted && !this._tinted && this._alpha == 1);
         return super.programVariantName | _loc1_ << 3;
      }
      
      override protected function createProgram() : starling.rendering.Program
      {
         var _loc1_:* = null;
         var _loc2_:* = null;
         if(texture)
         {
            if(this._optimizeIfNotTinted && !this._tinted && this._alpha == 1)
            {
               return super.createProgram();
            }
            _loc1_ = "m44 op, va0, vc0 \n" + "mov v0, va1      \n" + "mul v1, va2, vc4 \n";
            _loc2_ = tex("ft0","v0",0,texture) + "mul oc, ft0, v1  \n";
         }
         else
         {
            _loc1_ = "m44 op, va0, vc0 \n" + "mul v0, va2, vc4 \n";
            _loc2_ = "mov oc, v0       \n";
         }
         return starling.rendering.Program.fromSource(_loc1_,_loc2_);
      }
      
      override protected function beforeDraw(param1:Context3D) : void
      {
         super.beforeDraw(param1);
         sRenderAlpha[0] = sRenderAlpha[1] = sRenderAlpha[2] = sRenderAlpha[3] = this._alpha;
         param1.setProgramConstantsFromVector(Context3DProgramType.VERTEX,4,sRenderAlpha);
         if(this._tinted || this._alpha != 1 || !this._optimizeIfNotTinted || texture == null)
         {
            this.vertexFormat.setVertexBufferAt(2,vertexBuffer,"color");
         }
      }
      
      override protected function afterDraw(param1:Context3D) : void
      {
         param1.setVertexBufferAt(2,null);
         super.afterDraw(param1);
      }
      
      override public function get vertexFormat() : starling.rendering.VertexDataFormat
      {
         return VERTEX_FORMAT;
      }
      
      public function get alpha() : Number
      {
         return this._alpha;
      }
      
      public function set alpha(param1:Number) : void
      {
         this._alpha = param1;
      }
      
      public function get tinted() : Boolean
      {
         return this._tinted;
      }
      
      public function set tinted(param1:Boolean) : void
      {
         this._tinted = param1;
      }
   }
}
