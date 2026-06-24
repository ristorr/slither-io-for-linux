package starling.display.shaders
{
   import com.adobe.utils.AGALMiniAssembler;
   import flash.display3D.Context3D;
   import flash.utils.ByteArray;
   import starling.textures.Texture;
   
   public class AbstractShader implements IShader
   {
      
      private static var assembler:AGALMiniAssembler;
       
      
      protected var _opCode:ByteArray;
      
      public function AbstractShader()
      {
         super();
      }
      
      public function get opCode() : ByteArray
      {
         return this._opCode;
      }
      
      protected function compileAGAL(param1:String, param2:String) : void
      {
         if(!assembler)
         {
            assembler = new AGALMiniAssembler();
         }
         assembler.assemble(param1,param2);
         this._opCode = assembler.agalcode;
      }
      
      public function updateTextureAgal(param1:Texture) : void
      {
      }
      
      public function setConstants(param1:Context3D, param2:int) : void
      {
      }
   }
}
