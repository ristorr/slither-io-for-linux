package starling.textures
{
   import flash.display3D.Context3DTextureFormat;
   import flash.utils.ByteArray;
   
   public class AtfData
   {
       
      
      private var _format:String;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _numTextures:int;
      
      private var _isCubeMap:Boolean;
      
      private var _data:ByteArray;
      
      public function AtfData(param1:ByteArray)
      {
         var _loc3_:* = false;
         var _loc4_:* = 0;
         super();
         if(!isAtfData(param1))
         {
            throw new ArgumentError("Invalid ATF data");
         }
         if(param1[6] == 255)
         {
            param1.position = 12;
         }
         else
         {
            param1.position = 6;
         }
         var _loc2_:uint = param1.readUnsignedByte();
         switch(_loc2_ & 127)
         {
            case 0:
            case 1:
               this._format = Context3DTextureFormat.BGRA;
               break;
            case 12:
            case 2:
            case 3:
               this._format = Context3DTextureFormat.COMPRESSED;
               break;
            case 13:
            case 4:
            case 5:
               this._format = "compressedAlpha";
               break;
            default:
               throw new Error("Invalid ATF format");
         }
         this._width = Math.pow(2,param1.readUnsignedByte());
         this._height = Math.pow(2,param1.readUnsignedByte());
         this._numTextures = param1.readUnsignedByte();
         this._isCubeMap = (_loc2_ & 128) != 0;
         this._data = param1;
         if(param1[5] != 0 && param1[6] == 255)
         {
            _loc3_ = (param1[5] & 1) == 1;
            _loc4_ = param1[5] >> 1 & 127;
            this._numTextures = _loc3_ ? 1 : _loc4_;
         }
      }
      
      public static function isAtfData(param1:ByteArray) : Boolean
      {
         var _loc2_:String = null;
         if(param1.length < 3)
         {
            return false;
         }
         _loc2_ = String.fromCharCode(param1[0],param1[1],param1[2]);
         return _loc2_ == "ATF";
      }
      
      public function get format() : String
      {
         return this._format;
      }
      
      public function get width() : int
      {
         return this._width;
      }
      
      public function get height() : int
      {
         return this._height;
      }
      
      public function get numTextures() : int
      {
         return this._numTextures;
      }
      
      public function get isCubeMap() : Boolean
      {
         return this._isCubeMap;
      }
      
      public function get data() : ByteArray
      {
         return this._data;
      }
   }
}
