package starling.rendering
{
   import com.adobe.utils.AGALMiniAssembler;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DProgramType;
   import flash.display3D.Program3D;
   import flash.events.Event;
   import flash.utils.ByteArray;
   import starling.core.Starling;
   import starling.errors.MissingContextError;
   
   public class Program
   {
      
      private static var sAssembler:AGALMiniAssembler = new AGALMiniAssembler();
       
      
      private var _vertexShader:ByteArray;
      
      private var _fragmentShader:ByteArray;
      
      private var _program3D:Program3D;
      
      public function Program(param1:ByteArray, param2:ByteArray)
      {
         super();
         this._vertexShader = param1;
         this._fragmentShader = param2;
         Starling.current.stage3D.addEventListener(Event.CONTEXT3D_CREATE,this.onContextCreated,false,30,true);
      }
      
      public static function fromSource(param1:String, param2:String, param3:uint = 1) : Program
      {
         return new Program(sAssembler.assemble(Context3DProgramType.VERTEX,param1,param3),sAssembler.assemble(Context3DProgramType.FRAGMENT,param2,param3));
      }
      
      public function dispose() : void
      {
         Starling.current.stage3D.removeEventListener(Event.CONTEXT3D_CREATE,this.onContextCreated);
         this.disposeProgram();
      }
      
      public function activate(param1:Context3D = null) : void
      {
         if(param1 == null)
         {
            param1 = Starling.context;
            if(param1 == null)
            {
               throw new MissingContextError();
            }
         }
         if(this._program3D == null)
         {
            this._program3D = param1.createProgram();
            this._program3D.upload(this._vertexShader,this._fragmentShader);
         }
         param1.setProgram(this._program3D);
      }
      
      private function onContextCreated(param1:Event) : void
      {
         this.disposeProgram();
      }
      
      private function disposeProgram() : void
      {
         if(this._program3D)
         {
            this._program3D.dispose();
            this._program3D = null;
         }
      }
   }
}
