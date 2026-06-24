package org.villekoskela.utils
{
   import flash.geom.Rectangle;
   
   public class RectanglePacker
   {
      
      public static const VERSION:String = "1.3.0";
       
      
      private var mWidth:int = 0;
      
      private var mHeight:int = 0;
      
      private var mPadding:int = 8;
      
      private var mPackedWidth:int = 0;
      
      private var mPackedHeight:int = 0;
      
      private var mInsertList:Array;
      
      private var mInsertedRectangles:Vector.<org.villekoskela.utils.IntegerRectangle>;
      
      private var mFreeAreas:Vector.<org.villekoskela.utils.IntegerRectangle>;
      
      private var mNewFreeAreas:Vector.<org.villekoskela.utils.IntegerRectangle>;
      
      private var mOutsideRectangle:org.villekoskela.utils.IntegerRectangle;
      
      private var mSortableSizeStack:Vector.<org.villekoskela.utils.SortableSize>;
      
      private var mRectangleStack:Vector.<org.villekoskela.utils.IntegerRectangle>;
      
      public function RectanglePacker(param1:int, param2:int, param3:int = 0)
      {
         this.mInsertList = [];
         this.mInsertedRectangles = new Vector.<org.villekoskela.utils.IntegerRectangle>();
         this.mFreeAreas = new Vector.<org.villekoskela.utils.IntegerRectangle>();
         this.mNewFreeAreas = new Vector.<org.villekoskela.utils.IntegerRectangle>();
         this.mSortableSizeStack = new Vector.<org.villekoskela.utils.SortableSize>();
         this.mRectangleStack = new Vector.<org.villekoskela.utils.IntegerRectangle>();
         super();
         this.mOutsideRectangle = new org.villekoskela.utils.IntegerRectangle(param1 + 1,param2 + 1,0,0);
         this.reset(param1,param2,param3);
      }
      
      public function get rectangleCount() : int
      {
         return this.mInsertedRectangles.length;
      }
      
      public function get packedWidth() : int
      {
         return this.mPackedWidth;
      }
      
      public function get packedHeight() : int
      {
         return this.mPackedHeight;
      }
      
      public function get padding() : int
      {
         return this.mPadding;
      }
      
      public function reset(param1:int, param2:int, param3:int = 0) : void
      {
         while(this.mInsertedRectangles.length)
         {
            this.freeRectangle(this.mInsertedRectangles.pop());
         }
         while(this.mFreeAreas.length)
         {
            this.freeRectangle(this.mFreeAreas.pop());
         }
         this.mWidth = param1;
         this.mHeight = param2;
         this.mPackedWidth = 0;
         this.mPackedHeight = 0;
         this.mFreeAreas[0] = this.allocateRectangle(0,0,this.mWidth,this.mHeight);
         while(this.mInsertList.length)
         {
            this.freeSize(this.mInsertList.pop());
         }
         this.mPadding = param3;
      }
      
      public function getRectangle(param1:int, param2:flash.geom.Rectangle) : flash.geom.Rectangle
      {
         var _loc3_:org.villekoskela.utils.IntegerRectangle = this.mInsertedRectangles[param1];
         if(param2)
         {
            param2.x = _loc3_.x;
            param2.y = _loc3_.y;
            param2.width = _loc3_.width;
            param2.height = _loc3_.height;
            return param2;
         }
         return new flash.geom.Rectangle(_loc3_.x,_loc3_.y,_loc3_.width,_loc3_.height);
      }
      
      public function getRectangleId(param1:int) : int
      {
         var _loc2_:org.villekoskela.utils.IntegerRectangle = this.mInsertedRectangles[param1];
         return _loc2_.id;
      }
      
      public function insertRectangle(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:org.villekoskela.utils.SortableSize = this.allocateSize(param1,param2,param3);
         this.mInsertList.push(_loc4_);
      }
      
      public function packRectangles(param1:Boolean = true) : int
      {
         var _loc2_:org.villekoskela.utils.SortableSize = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:org.villekoskela.utils.IntegerRectangle = null;
         var _loc7_:org.villekoskela.utils.IntegerRectangle = null;
         if(param1)
         {
            this.mInsertList.sortOn("width",Array.NUMERIC);
         }
         while(this.mInsertList.length > 0)
         {
            _loc2_ = this.mInsertList.pop() as org.villekoskela.utils.SortableSize;
            _loc3_ = _loc2_.width;
            _loc4_ = _loc2_.height;
            if((_loc5_ = this.getFreeAreaIndex(_loc3_,_loc4_)) >= 0)
            {
               _loc6_ = this.mFreeAreas[_loc5_];
               (_loc7_ = this.allocateRectangle(_loc6_.x,_loc6_.y,_loc3_,_loc4_)).id = _loc2_.id;
               this.generateNewFreeAreas(_loc7_,this.mFreeAreas,this.mNewFreeAreas);
               while(this.mNewFreeAreas.length > 0)
               {
                  this.mFreeAreas[this.mFreeAreas.length] = this.mNewFreeAreas.pop();
               }
               this.mInsertedRectangles[this.mInsertedRectangles.length] = _loc7_;
               if(_loc7_.right > this.mPackedWidth)
               {
                  this.mPackedWidth = _loc7_.right;
               }
               if(_loc7_.bottom > this.mPackedHeight)
               {
                  this.mPackedHeight = _loc7_.bottom;
               }
            }
            this.freeSize(_loc2_);
         }
         return this.rectangleCount;
      }
      
      private function filterSelfSubAreas(param1:Vector.<org.villekoskela.utils.IntegerRectangle>) : void
      {
         var _loc3_:org.villekoskela.utils.IntegerRectangle = null;
         var _loc4_:int = 0;
         var _loc5_:org.villekoskela.utils.IntegerRectangle = null;
         var _loc6_:org.villekoskela.utils.IntegerRectangle = null;
         var _loc2_:int = int(param1.length - 1);
         while(_loc2_ >= 0)
         {
            _loc3_ = param1[_loc2_];
            _loc4_ = int(param1.length - 1);
            while(_loc4_ >= 0)
            {
               if(_loc2_ != _loc4_)
               {
                  _loc5_ = param1[_loc4_];
                  if(_loc3_.x >= _loc5_.x && _loc3_.y >= _loc5_.y && _loc3_.right <= _loc5_.right && _loc3_.bottom <= _loc5_.bottom)
                  {
                     this.freeRectangle(_loc3_);
                     _loc6_ = param1.pop();
                     if(_loc2_ < param1.length)
                     {
                        param1[_loc2_] = _loc6_;
                     }
                     break;
                  }
               }
               _loc4_--;
            }
            _loc2_--;
         }
      }
      
      private function generateNewFreeAreas(param1:org.villekoskela.utils.IntegerRectangle, param2:Vector.<org.villekoskela.utils.IntegerRectangle>, param3:Vector.<org.villekoskela.utils.IntegerRectangle>) : void
      {
         var _loc10_:org.villekoskela.utils.IntegerRectangle = null;
         var _loc11_:org.villekoskela.utils.IntegerRectangle = null;
         var _loc4_:int = param1.x;
         var _loc5_:int = param1.y;
         var _loc6_:int = param1.right + 1 + this.mPadding;
         var _loc7_:int = param1.bottom + 1 + this.mPadding;
         var _loc8_:org.villekoskela.utils.IntegerRectangle = null;
         if(this.mPadding == 0)
         {
            _loc8_ = param1;
         }
         var _loc9_:int = int(param2.length - 1);
         while(_loc9_ >= 0)
         {
            _loc10_ = param2[_loc9_];
            if(!(_loc4_ >= _loc10_.right || _loc6_ <= _loc10_.x || _loc5_ >= _loc10_.bottom || _loc7_ <= _loc10_.y))
            {
               if(!_loc8_)
               {
                  _loc8_ = this.allocateRectangle(param1.x,param1.y,param1.width + this.mPadding,param1.height + this.mPadding);
               }
               this.generateDividedAreas(_loc8_,_loc10_,param3);
               _loc11_ = param2.pop();
               if(_loc9_ < param2.length)
               {
                  param2[_loc9_] = _loc11_;
               }
            }
            _loc9_--;
         }
         if(Boolean(_loc8_) && _loc8_ != param1)
         {
            this.freeRectangle(_loc8_);
         }
         this.filterSelfSubAreas(param3);
      }
      
      private function generateDividedAreas(param1:org.villekoskela.utils.IntegerRectangle, param2:org.villekoskela.utils.IntegerRectangle, param3:Vector.<org.villekoskela.utils.IntegerRectangle>) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int;
         if((_loc5_ = param2.right - param1.right) > 0)
         {
            param3[param3.length] = this.allocateRectangle(param1.right,param2.y,_loc5_,param2.height);
            _loc4_++;
         }
         var _loc6_:int;
         if((_loc6_ = param1.x - param2.x) > 0)
         {
            param3[param3.length] = this.allocateRectangle(param2.x,param2.y,_loc6_,param2.height);
            _loc4_++;
         }
         var _loc7_:int;
         if((_loc7_ = param2.bottom - param1.bottom) > 0)
         {
            param3[param3.length] = this.allocateRectangle(param2.x,param1.bottom,param2.width,_loc7_);
            _loc4_++;
         }
         var _loc8_:*;
         if((_loc8_ = param1.y - param2.y) > 0)
         {
            param3[param3.length] = this.allocateRectangle(param2.x,param2.y,param2.width,_loc8_);
            _loc4_++;
         }
         if(_loc4_ == 0 && (param1.width < param2.width || param1.height < param2.height))
         {
            param3[param3.length] = param2;
         }
         else
         {
            this.freeRectangle(param2);
         }
      }
      
      private function getFreeAreaIndex(param1:int, param2:int) : int
      {
         var _loc9_:org.villekoskela.utils.IntegerRectangle = null;
         var _loc3_:org.villekoskela.utils.IntegerRectangle = this.mOutsideRectangle;
         var _loc4_:int = -1;
         var _loc5_:int = param1 + this.mPadding;
         var _loc6_:int = param2 + this.mPadding;
         var _loc7_:int;
         var _loc8_:int = (_loc7_ = int(this.mFreeAreas.length)) - 1;
         while(_loc8_ >= 0)
         {
            if((_loc9_ = this.mFreeAreas[_loc8_]).x < this.mPackedWidth || _loc9_.y < this.mPackedHeight)
            {
               if(_loc9_.x < _loc3_.x && _loc5_ <= _loc9_.width && _loc6_ <= _loc9_.height)
               {
                  _loc4_ = _loc8_;
                  if(_loc5_ == _loc9_.width && _loc9_.width <= _loc9_.height && _loc9_.right < this.mWidth || _loc6_ == _loc9_.height && _loc9_.height <= _loc9_.width)
                  {
                     break;
                  }
                  _loc3_ = _loc9_;
               }
            }
            else if(_loc9_.x < _loc3_.x && param1 <= _loc9_.width && param2 <= _loc9_.height)
            {
               _loc4_ = _loc8_;
               if(param1 == _loc9_.width && _loc9_.width <= _loc9_.height && _loc9_.right < this.mWidth || param2 == _loc9_.height && _loc9_.height <= _loc9_.width)
               {
                  break;
               }
               _loc3_ = _loc9_;
            }
            _loc8_--;
         }
         return _loc4_;
      }
      
      private function allocateRectangle(param1:int, param2:int, param3:int, param4:int) : org.villekoskela.utils.IntegerRectangle
      {
         var _loc5_:org.villekoskela.utils.IntegerRectangle = null;
         if(this.mRectangleStack.length > 0)
         {
            (_loc5_ = this.mRectangleStack.pop()).x = param1;
            _loc5_.y = param2;
            _loc5_.width = param3;
            _loc5_.height = param4;
            _loc5_.right = param1 + param3;
            _loc5_.bottom = param2 + param4;
            return _loc5_;
         }
         return new org.villekoskela.utils.IntegerRectangle(param1,param2,param3,param4);
      }
      
      private function freeRectangle(param1:org.villekoskela.utils.IntegerRectangle) : void
      {
         this.mRectangleStack[this.mRectangleStack.length] = param1;
      }
      
      private function allocateSize(param1:int, param2:int, param3:int) : org.villekoskela.utils.SortableSize
      {
         var _loc4_:org.villekoskela.utils.SortableSize = null;
         if(this.mSortableSizeStack.length > 0)
         {
            (_loc4_ = this.mSortableSizeStack.pop()).width = param1;
            _loc4_.height = param2;
            _loc4_.id = param3;
            return _loc4_;
         }
         return new org.villekoskela.utils.SortableSize(param1,param2,param3);
      }
      
      private function freeSize(param1:org.villekoskela.utils.SortableSize) : void
      {
         this.mSortableSizeStack[this.mSortableSizeStack.length] = param1;
      }
   }
}
