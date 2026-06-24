package starling.display.shaders.fragment
{
   import flash.display3D.Context3DProgramType;
   import starling.display.shaders.AbstractShader;
   
   public class VertexColorFragmentShader extends AbstractShader
   {
       
      
      public function VertexColorFragmentShader()
      {
         super();
         compileAGAL(Context3DProgramType.FRAGMENT,"mul oc, v0, fc0");
      }
   }
}
