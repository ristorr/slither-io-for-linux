package starling.display
{
   import flash.display3D.Context3DBlendFactor;
   import starling.core.Starling;
   
   public class BlendMode
   {
      
      private static var sBlendModes:Object;
      
      public static const AUTO:String = "auto";
      
      public static const NONE:String = "none";
      
      public static const NORMAL:String = "normal";
      
      public static const ADD:String = "add";
      
      public static const MULTIPLY:String = "multiply";
      
      public static const SCREEN:String = "screen";
      
      public static const ERASE:String = "erase";
      
      public static const MASK:String = "mask";
      
      public static const BELOW:String = "below";
       
      
      private var _name:String;
      
      private var _sourceFactor:String;
      
      private var _destinationFactor:String;
      
      public function BlendMode(param1:String, param2:String, param3:String)
      {
         super();
         this._name = param1;
         this._sourceFactor = param2;
         this._destinationFactor = param3;
      }
      
      public static function get(param1:String) : starling.display.BlendMode
      {
         if(sBlendModes == null)
         {
            registerDefaults();
         }
         if(param1 in sBlendModes)
         {
            return sBlendModes[param1];
         }
         throw new ArgumentError("Blend mode not found: " + param1);
      }
      
      public static function register(param1:String, param2:String, param3:String) : starling.display.BlendMode
      {
         if(sBlendModes == null)
         {
            registerDefaults();
         }
         var _loc4_:starling.display.BlendMode = new starling.display.BlendMode(param1,param2,param3);
         sBlendModes[param1] = _loc4_;
         return _loc4_;
      }
      
      private static function registerDefaults() : void
      {
         if(sBlendModes)
         {
            return;
         }
         sBlendModes = {};
         register("none",Context3DBlendFactor.ONE,Context3DBlendFactor.ZERO);
         register("normal",Context3DBlendFactor.ONE,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
         register("add",Context3DBlendFactor.ONE,Context3DBlendFactor.ONE);
         register("multiply",Context3DBlendFactor.DESTINATION_COLOR,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
         register("screen",Context3DBlendFactor.ONE,Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR);
         register("erase",Context3DBlendFactor.ZERO,Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
         register("mask",Context3DBlendFactor.ZERO,Context3DBlendFactor.SOURCE_ALPHA);
         register("below",Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA,Context3DBlendFactor.DESTINATION_ALPHA);
      }
      
      public static function getAll(param1:Array = null) : Array
      {
         var _loc2_:starling.display.BlendMode = null;
         param1 ||= [];
         if(sBlendModes == null)
         {
            registerDefaults();
         }
         for each(_loc2_ in sBlendModes)
         {
            param1.insertAt(0,_loc2_);
         }
         return param1;
      }
      
      public static function isRegistered(param1:String) : Boolean
      {
         return param1 in sBlendModes;
      }
      
      public function activate() : void
      {
         Starling.context.setBlendFactors(this._sourceFactor,this._destinationFactor);
      }
      
      public function toString() : String
      {
         return this._name;
      }
      
      public function get sourceFactor() : String
      {
         return this._sourceFactor;
      }
      
      public function get destinationFactor() : String
      {
         return this._destinationFactor;
      }
      
      public function get name() : String
      {
         return this._name;
      }
   }
}
