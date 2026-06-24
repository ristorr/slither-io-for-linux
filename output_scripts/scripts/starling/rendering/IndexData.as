package starling.rendering
{
   import flash.display3D.Context3D;
   import flash.display3D.IndexBuffer3D;
   import flash.errors.EOFError;
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   import starling.core.Starling;
   import starling.errors.MissingContextError;
   import starling.utils.StringUtil;
   
   public class IndexData
   {
      
      private static const INDEX_SIZE:int = 2;
      
      private static var sQuadData:ByteArray = new ByteArray();
      
      private static var sQuadDataNumIndices:uint = 0;
      
      private static var sVector:Vector.<uint> = new Vector.<uint>(0);
      
      private static var sTrimData:ByteArray = new ByteArray();
       
      
      private var _rawData:ByteArray;
      
      private var _numIndices:int;
      
      private var _initialCapacity:int;
      
      private var _useQuadLayout:Boolean;
      
      public function IndexData(param1:int = 48)
      {
         super();
         this._numIndices = 0;
         this._initialCapacity = param1;
         this._useQuadLayout = true;
      }
      
      private static function getBasicQuadIndexAt(param1:int) : int
      {
         var _loc4_:int = 0;
         var _loc2_:int = param1 / 6;
         var _loc3_:int = param1 - _loc2_ * 6;
         if(_loc3_ == 0)
         {
            _loc4_ = 0;
         }
         else if(_loc3_ == 1 || _loc3_ == 3)
         {
            _loc4_ = 1;
         }
         else if(_loc3_ == 2 || _loc3_ == 5)
         {
            _loc4_ = 2;
         }
         else
         {
            _loc4_ = 3;
         }
         return _loc2_ * 4 + _loc4_;
      }
      
      public function clear() : void
      {
         if(this._rawData)
         {
            this._rawData.clear();
         }
         this._numIndices = 0;
         this._useQuadLayout = true;
      }
      
      public function clone() : starling.rendering.IndexData
      {
         var _loc1_:starling.rendering.IndexData = new starling.rendering.IndexData(this._numIndices);
         if(!this._useQuadLayout)
         {
            _loc1_.switchToGenericData();
            _loc1_._rawData.writeBytes(this._rawData);
         }
         _loc1_._numIndices = this._numIndices;
         return _loc1_;
      }
      
      public function copyTo(param1:starling.rendering.IndexData, param2:int = 0, param3:int = 0, param4:int = 0, param5:int = -1) : void
      {
         var _loc6_:ByteArray = null;
         var _loc7_:ByteArray = null;
         var _loc9_:Boolean = false;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:uint = 0;
         var _loc15_:uint = 0;
         var _loc16_:uint = 0;
         if(param5 < 0 || param4 + param5 > this._numIndices)
         {
            param5 = this._numIndices - param4;
         }
         var _loc8_:int = param2 + param5;
         if(param1._numIndices < _loc8_)
         {
            param1._numIndices = _loc8_;
            if(sQuadDataNumIndices < _loc8_)
            {
               this.ensureQuadDataCapacity(_loc8_);
            }
         }
         if(this._useQuadLayout)
         {
            if(param1._useQuadLayout)
            {
               _loc9_ = true;
               _loc11_ = (_loc10_ = param2 - param4) / 6;
               _loc12_ = param3 / 4;
               if(_loc11_ == _loc12_ && (param3 & 3) == 0 && _loc11_ * 6 == _loc10_)
               {
                  _loc9_ = true;
               }
               else if(param5 > 2)
               {
                  _loc9_ = false;
               }
               else
               {
                  _loc13_ = 0;
                  while(_loc13_ < param5)
                  {
                     _loc9_ &&= getBasicQuadIndexAt(param4 + _loc13_) + param3 == getBasicQuadIndexAt(param2 + _loc13_);
                     _loc13_++;
                  }
               }
               if(_loc9_)
               {
                  return;
               }
               param1.switchToGenericData();
            }
            _loc6_ = sQuadData;
            _loc7_ = param1._rawData;
            if((param3 & 3) == 0)
            {
               param4 += 6 * param3 / 4;
               param3 = 0;
               this.ensureQuadDataCapacity(param4 + param5);
            }
         }
         else
         {
            if(param1._useQuadLayout)
            {
               param1.switchToGenericData();
            }
            _loc6_ = this._rawData;
            _loc7_ = param1._rawData;
         }
         _loc7_.position = param2 * INDEX_SIZE;
         if(param3 == 0)
         {
            _loc7_.writeBytes(_loc6_,param4 * INDEX_SIZE,param5 * INDEX_SIZE);
         }
         else
         {
            _loc6_.position = param4 * INDEX_SIZE;
            while(param5 > 1)
            {
               _loc15_ = uint((((_loc14_ = _loc6_.readUnsignedInt()) & 4294901760) >> 16) + param3);
               _loc16_ = uint((_loc14_ & 65535) + param3);
               _loc7_.writeUnsignedInt(_loc15_ << 16 | _loc16_);
               param5 -= 2;
            }
            if(param5)
            {
               _loc7_.writeShort(_loc6_.readUnsignedShort() + param3);
            }
         }
      }
      
      public function setIndex(param1:int, param2:uint) : void
      {
         if(this._numIndices < param1 + 1)
         {
            this.numIndices = param1 + 1;
         }
         if(this._useQuadLayout)
         {
            if(getBasicQuadIndexAt(param1) == param2)
            {
               return;
            }
            this.switchToGenericData();
         }
         this._rawData.position = param1 * INDEX_SIZE;
         this._rawData.writeShort(param2);
      }
      
      public function getIndex(param1:int) : int
      {
         if(this._useQuadLayout)
         {
            if(param1 < this._numIndices)
            {
               return getBasicQuadIndexAt(param1);
            }
            throw new EOFError();
         }
         this._rawData.position = param1 * INDEX_SIZE;
         return this._rawData.readUnsignedShort();
      }
      
      public function offsetIndices(param1:int, param2:int = 0, param3:int = -1) : void
      {
         if(param3 < 0 || param2 + param3 > this._numIndices)
         {
            param3 = this._numIndices - param2;
         }
         var _loc4_:int = param2 + param3;
         var _loc5_:int = param2;
         while(_loc5_ < _loc4_)
         {
            this.setIndex(_loc5_,this.getIndex(_loc5_) + param1);
            _loc5_++;
         }
      }
      
      public function addTriangle(param1:uint, param2:uint, param3:uint) : void
      {
         var _loc4_:* = false;
         var _loc5_:* = false;
         if(this._useQuadLayout)
         {
            if(param1 == getBasicQuadIndexAt(this._numIndices))
            {
               if((_loc5_ = !(_loc4_ = (this._numIndices & 1) != 0)) && param2 == param1 + 1 && param3 == param2 + 1 || _loc4_ && param3 == param1 + 1 && param2 == param3 + 1)
               {
                  this._numIndices += 3;
                  this.ensureQuadDataCapacity(this._numIndices);
                  return;
               }
            }
            this.switchToGenericData();
         }
         this._rawData.position = this._numIndices * INDEX_SIZE;
         this._rawData.writeShort(param1);
         this._rawData.writeShort(param2);
         this._rawData.writeShort(param3);
         this._numIndices += 3;
      }
      
      public function addQuad(param1:uint, param2:uint, param3:uint, param4:uint) : void
      {
         if(this._useQuadLayout)
         {
            if(param1 == getBasicQuadIndexAt(this._numIndices) && param2 == param1 + 1 && param3 == param2 + 1 && param4 == param3 + 1)
            {
               this._numIndices += 6;
               this.ensureQuadDataCapacity(this._numIndices);
               return;
            }
            this.switchToGenericData();
         }
         this._rawData.position = this._numIndices * INDEX_SIZE;
         this._rawData.writeShort(param1);
         this._rawData.writeShort(param2);
         this._rawData.writeShort(param3);
         this._rawData.writeShort(param2);
         this._rawData.writeShort(param4);
         this._rawData.writeShort(param3);
         this._numIndices += 6;
      }
      
      public function toVector(param1:Vector.<uint> = null) : Vector.<uint>
      {
         if(param1 == null)
         {
            param1 = new Vector.<uint>(this._numIndices);
         }
         else
         {
            param1.length = this._numIndices;
         }
         var _loc2_:ByteArray = this._useQuadLayout ? sQuadData : this._rawData;
         _loc2_.position = 0;
         var _loc3_:int = 0;
         while(_loc3_ < this._numIndices)
         {
            param1[_loc3_] = _loc2_.readUnsignedShort();
            _loc3_++;
         }
         return param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = StringUtil.format("[IndexData numIndices={0} indices=\"{1}\"]",this._numIndices,this.toVector(sVector).join());
         sVector.length = 0;
         return _loc1_;
      }
      
      private function switchToGenericData() : void
      {
         if(this._useQuadLayout)
         {
            this._useQuadLayout = false;
            if(this._rawData == null)
            {
               this._rawData = new ByteArray();
               this._rawData.endian = Endian.LITTLE_ENDIAN;
               this._rawData.length = this._initialCapacity * INDEX_SIZE;
               this._rawData.length = this._numIndices * INDEX_SIZE;
            }
            if(this._numIndices)
            {
               this._rawData.writeBytes(sQuadData,0,this._numIndices * INDEX_SIZE);
            }
         }
      }
      
      private function ensureQuadDataCapacity(param1:int) : void
      {
         var _loc2_:int = 0;
         if(sQuadDataNumIndices >= param1)
         {
            return;
         }
         var _loc3_:int = sQuadDataNumIndices / 6;
         var _loc4_:int = Math.ceil(param1 / 6);
         sQuadData.endian = Endian.LITTLE_ENDIAN;
         sQuadData.position = sQuadData.length;
         sQuadDataNumIndices = _loc4_ * 6;
         _loc2_ = _loc3_;
         while(_loc2_ < _loc4_)
         {
            sQuadData.writeShort(4 * _loc2_);
            sQuadData.writeShort(4 * _loc2_ + 1);
            sQuadData.writeShort(4 * _loc2_ + 2);
            sQuadData.writeShort(4 * _loc2_ + 1);
            sQuadData.writeShort(4 * _loc2_ + 3);
            sQuadData.writeShort(4 * _loc2_ + 2);
            _loc2_++;
         }
      }
      
      public function createIndexBuffer(param1:Boolean = false, param2:String = "staticDraw") : IndexBuffer3D
      {
         var _loc3_:Context3D = Starling.context;
         if(_loc3_ == null)
         {
            throw new MissingContextError();
         }
         if(this._numIndices == 0)
         {
            return null;
         }
         var _loc4_:IndexBuffer3D = _loc3_.createIndexBuffer(this._numIndices,param2);
         if(param1)
         {
            this.uploadToIndexBuffer(_loc4_);
         }
         return _loc4_;
      }
      
      public function uploadToIndexBuffer(param1:IndexBuffer3D, param2:int = 0, param3:int = -1) : void
      {
         if(param3 < 0 || param2 + param3 > this._numIndices)
         {
            param3 = this._numIndices - param2;
         }
         if(param3 > 0)
         {
            param1.uploadFromByteArray(this.rawData,0,param2,param3);
         }
      }
      
      public function trim() : void
      {
         if(this._useQuadLayout)
         {
            return;
         }
         sTrimData.length = this._rawData.length;
         sTrimData.position = 0;
         sTrimData.writeBytes(this._rawData);
         this._rawData.clear();
         this._rawData.length = sTrimData.length;
         this._rawData.writeBytes(sTrimData);
         sTrimData.clear();
      }
      
      public function get numIndices() : int
      {
         return this._numIndices;
      }
      
      public function set numIndices(param1:int) : void
      {
         if(param1 != this._numIndices)
         {
            if(this._useQuadLayout)
            {
               this.ensureQuadDataCapacity(param1);
            }
            else
            {
               this._rawData.length = param1 * INDEX_SIZE;
            }
            if(param1 == 0)
            {
               this._useQuadLayout = true;
            }
            this._numIndices = param1;
         }
      }
      
      public function get numTriangles() : int
      {
         return this._numIndices / 3;
      }
      
      public function set numTriangles(param1:int) : void
      {
         this.numIndices = param1 * 3;
      }
      
      public function get numQuads() : int
      {
         return this._numIndices / 6;
      }
      
      public function set numQuads(param1:int) : void
      {
         this.numIndices = param1 * 6;
      }
      
      public function get indexSizeInBytes() : int
      {
         return INDEX_SIZE;
      }
      
      public function get useQuadLayout() : Boolean
      {
         return this._useQuadLayout;
      }
      
      public function set useQuadLayout(param1:Boolean) : void
      {
         if(param1 != this._useQuadLayout)
         {
            if(param1)
            {
               this.ensureQuadDataCapacity(this._numIndices);
               this._rawData.length = 0;
               this._useQuadLayout = true;
            }
            else
            {
               this.switchToGenericData();
            }
         }
      }
      
      public function get rawData() : ByteArray
      {
         if(this._useQuadLayout)
         {
            return sQuadData;
         }
         return this._rawData;
      }
   }
}
