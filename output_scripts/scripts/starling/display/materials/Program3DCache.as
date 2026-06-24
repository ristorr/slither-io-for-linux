package starling.display.materials
{
   import flash.display3D.Context3D;
   import flash.display3D.Program3D;
   import flash.utils.Dictionary;
   import starling.display.shaders.IShader;
   
   internal class Program3DCache
   {
      
      private static const LAZY_CACHE_SIZE:uint = 8;
      
      private static var uid:int = 0;
      
      private static var uidByShaderTable:Dictionary = new Dictionary(true);
      
      private static var programByUIDTable:Object = {};
      
      private static var uidByProgramTable:Dictionary = new Dictionary(false);
      
      private static var numReferencesByProgramTable:Dictionary = new Dictionary();
      
      private static var cacheSize:uint;
       
      
      public function Program3DCache()
      {
         super();
      }
      
      public static function getProgram3D(param1:Context3D, param2:IShader, param3:IShader) : Program3D
      {
         var _loc4_:int;
         if((_loc4_ = int(uidByShaderTable[param2])) == 0)
         {
            _loc4_ = int(uidByShaderTable[param2] = ++uid);
         }
         var _loc5_:int;
         if((_loc5_ = int(uidByShaderTable[param3])) == 0)
         {
            _loc5_ = int(uidByShaderTable[param3] = ++uid);
         }
         var _loc6_:String = _loc4_ + "_" + _loc5_;
         var _loc7_:Program3D;
         if((_loc7_ = programByUIDTable[_loc6_]) == null)
         {
            _loc7_ = programByUIDTable[_loc6_] = param1.createProgram();
            uidByProgramTable[_loc7_] = _loc6_;
            _loc7_.upload(param2.opCode,param3.opCode);
            numReferencesByProgramTable[_loc7_] = 0;
            ++cacheSize;
         }
         ++numReferencesByProgramTable[_loc7_];
         if(cacheSize > LAZY_CACHE_SIZE)
         {
            flush();
         }
         return _loc7_;
      }
      
      public static function releaseProgram3D(param1:Program3D, param2:Boolean = false) : void
      {
         if(!numReferencesByProgramTable[param1])
         {
            throw new Error("Program3D is not in cache");
         }
         --numReferencesByProgramTable[param1];
         if(param2)
         {
            flush();
         }
      }
      
      private static function flush() : void
      {
         var _loc1_:String = null;
         var _loc2_:Program3D = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         for(_loc1_ in programByUIDTable)
         {
            _loc2_ = programByUIDTable[_loc1_];
            _loc3_ = int(numReferencesByProgramTable[_loc2_]);
            if(_loc3_ <= 0)
            {
               _loc2_.dispose();
               delete numReferencesByProgramTable[_loc2_];
               _loc4_ = String(uidByProgramTable[_loc2_]);
               delete programByUIDTable[_loc4_];
               delete uidByProgramTable[_loc2_];
               --cacheSize;
               return;
            }
         }
      }
   }
}
