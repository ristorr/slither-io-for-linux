package hypah.hex
{
   import flash.utils.*;
   
   public class Hex
   {
      
      public static var oct = "0123456789ABCDEF";
      
      public static var octz = [48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70];
      
      private static var octa:Vector.<int> = new Vector.<int>(256);
      
      private static var initialized = false;
       
      
      public function Hex()
      {
         super();
      }
      
      private static function init() : *
      {
         var _loc1_:* = undefined;
         if(!initialized)
         {
            _loc1_ = 0;
            while(_loc1_ < 256)
            {
               octa[_loc1_] = 0;
               if(_loc1_ >= 48 && _loc1_ <= 57)
               {
                  octa[_loc1_] = _loc1_ - 48;
               }
               else if(_loc1_ >= 65 && _loc1_ <= 70)
               {
                  octa[_loc1_] = _loc1_ - 55;
               }
               else if(_loc1_ >= 97 && _loc1_ <= 122)
               {
                  octa[_loc1_] = _loc1_ - 87;
               }
               _loc1_++;
            }
            initialized = true;
         }
      }
      
      public static function hexed(param1:ByteArray, param2:int = 2147483647) : *
      {
         var _loc4_:int = 0;
         if(!initialized)
         {
            init();
         }
         var _loc3_:ByteArray = new ByteArray();
         var _loc5_:int;
         if((_loc5_ = int(param1.length)) > param2)
         {
            _loc5_ = param2;
         }
         var _loc6_:* = 0;
         while(_loc6_ < _loc5_)
         {
            _loc4_ = int(param1[_loc6_]);
            _loc3_.writeByte(octz[_loc4_ >> 4 & 15]);
            _loc3_.writeByte(octz[_loc4_ & 15]);
            _loc6_++;
         }
         return "" + _loc3_;
      }
      
      public static function hexedByte(param1:int) : *
      {
         if(!initialized)
         {
            init();
         }
         return oct.charAt(param1 >> 4 & 15) + oct.charAt(param1 & 15);
      }
      
      public static function hexedStr(param1:String, param2:int = 2147483647) : *
      {
         var _loc4_:int = 0;
         if(!initialized)
         {
            init();
         }
         var _loc3_:Array = new Array();
         var _loc5_:int;
         if((_loc5_ = param1.length) > param2)
         {
            _loc5_ = param2;
         }
         var _loc6_:* = 0;
         while(_loc6_ < _loc5_)
         {
            _loc4_ = param1.charCodeAt(_loc6_);
            _loc3_.push(oct.charAt(_loc4_ >> 4 & 15) + oct.charAt(_loc4_ & 15));
            _loc6_++;
         }
         return _loc3_.join("");
      }
      
      public static function unhexed(param1:String) : *
      {
         var _loc5_:int = 0;
         if(!initialized)
         {
            init();
         }
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUTFBytes(param1);
         var _loc3_:int = int(_loc2_.length);
         var _loc4_:ByteArray;
         (_loc4_ = new ByteArray()).length = _loc3_ / 2;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         _loc6_ = 0;
         while(_loc6_ < _loc3_)
         {
            var _loc8_:*;
            _loc4_[_loc8_ = _loc7_++] = (octa[_loc2_[_loc6_]] << 4) + octa[_loc2_[_loc6_ + 1]];
            _loc6_ += 2;
         }
         _loc4_.position = 0;
         return _loc4_;
      }
      
      public static function hexToInt(param1:String) : *
      {
         if(!initialized)
         {
            init();
         }
         var _loc2_:* = 0;
         var _loc3_:int = param1.length;
         var _loc4_:* = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ <<= 8;
            _loc2_ += (octa[param1.charCodeAt(_loc4_)] << 4) + octa[param1.charCodeAt(_loc4_ + 1)];
            _loc4_ += 2;
         }
         return _loc2_;
      }
   }
}
