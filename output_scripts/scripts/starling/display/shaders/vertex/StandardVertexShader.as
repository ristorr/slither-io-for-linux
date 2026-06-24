package starling.display.shaders.vertex
{
   import flash.display3D.Context3DProgramType;
   import starling.display.shaders.AbstractShader;
   
   public class StandardVertexShader extends AbstractShader
   {
       
      
      public function StandardVertexShader()
      {
         super();
         var _loc1_:* = "m44 op, va0, vc0 \n" + "mov v0, va1 \n" + "mov v1, va2 \n";
         compileAGAL(Context3DProgramType.VERTEX,_loc1_);
      }
   }
}
