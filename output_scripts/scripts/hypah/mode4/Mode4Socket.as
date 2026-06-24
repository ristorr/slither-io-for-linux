package hypah.mode4
{
   import flash.events.*;
   import flash.net.*;
   import flash.system.*;
   import flash.utils.*;
   import hypah.hex.*;
   
   public dynamic class Mode4Socket
   {
       
      
      public var x:Socket = null;
      
      public var ip:String;
      
      public var port:int;
      
      public var connecting:Boolean = false;
      
      public var did_connect:Boolean = false;
      
      public var pending:Boolean = false;
      
      public var hpd:Boolean = false;
      
      public var sba:ByteArray;
      
      public var sl:int = 0;
      
      public var ba:ByteArray;
      
      public var onConnect;
      
      public var onClose;
      
      public var onError;
      
      public var receive;
      
      private var hal = false;
      
      private var forced_close:Boolean = false;
      
      private var tl:int = -1;
      
      public var hbc:int = 4;
      
      public function Mode4Socket()
      {
         this.sba = new ByteArray();
         this.ba = new ByteArray();
         this.onConnect = function():*
         {
            trace("need to override onConnect() function in a Mode4Socket");
         };
         this.onClose = function():*
         {
            trace("need to override onClose() function in a Mode4Socket");
         };
         this.onError = function():*
         {
            trace("need to override onError() function in a Mode4Socket");
         };
         this.receive = function(param1:ByteArray):*
         {
         };
         super();
         try
         {
            this.x = new Socket();
         }
         catch(e:IOErrorEvent)
         {
            trace("what the...");
            x = null;
            return;
         }
         catch(e:*)
         {
            trace("what the...");
            x = null;
            return;
         }
         this.x.addEventListener(Event.CLOSE,this.onClose_internal);
         this.x.addEventListener(Event.CONNECT,this.onConnect_internal);
         this.x.addEventListener(ErrorEvent.ERROR,this.onError_internal);
         this.x.addEventListener(IOErrorEvent.IO_ERROR,this.onError_internal);
         this.x.addEventListener(ProgressEvent.SOCKET_DATA,this.onPartialData,false,999999);
         this.x.tcpNoDelay = true;
         this.hal = true;
      }
      
      public function connect(param1:String, param2:int) : void
      {
         this.connecting = true;
         this.forced_close = false;
         if(this.x != null)
         {
            this.ip = param1;
            this.port = param2;
            this.x.connect(param1,param2);
         }
      }
      
      public function close() : *
      {
         this.connecting = false;
         this.did_connect = false;
         this.onClose_internal("");
         if(!this.forced_close)
         {
            if(this.x != null)
            {
               try
               {
                  this.forced_close = true;
                  this.x.close();
               }
               catch(e:*)
               {
               }
            }
         }
      }
      
      public function send(param1:String) : *
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUTFBytes(param1);
         this.sendBytes(_loc2_);
      }
      
      public function sendBytes(param1:ByteArray) : *
      {
         var l:int;
         var ba:ByteArray = param1;
         if(ba.length >= 16777215)
         {
            trace("tried sending invalid packet; length is too long;  " + ba.length);
            return;
         }
         l = int(ba.length);
         if(this.hbc == 4)
         {
            this.sba.writeByte(l >> 24 & 255);
            this.sba.writeByte(l >> 16 & 255);
            this.sba.writeByte(l >> 8 & 255);
            this.sba.writeByte(l & 255);
         }
         else if(this.hbc == 3)
         {
            this.sba.writeByte(l >> 16 & 255);
            this.sba.writeByte(l >> 8 & 255);
            this.sba.writeByte(l & 255);
         }
         else if(this.hbc == 2)
         {
            this.sba.writeByte(l >> 8 & 255);
            this.sba.writeByte(l & 255);
         }
         else if(this.hbc == 1)
         {
            this.sba.writeByte(l & 255);
         }
         this.sba.writeBytes(ba);
         this.sl += this.hbc + l;
         if(this.pending)
         {
            if(!this.hpd)
            {
               this.hpd = true;
            }
         }
         else if(this.x != null)
         {
            try
            {
               this.x.writeBytes(this.sba,0,this.sl);
               this.sba.position = 0;
               this.sl = 0;
               this.x.flush();
            }
            catch(e:*)
            {
               close();
            }
         }
      }
      
      public function sendAndFlush() : *
      {
         if(this.hpd)
         {
            this.hpd = false;
            if(this.x != null)
            {
               try
               {
                  this.x.writeBytes(this.sba,0,this.sl);
                  this.sba.position = 0;
                  this.sl = 0;
                  this.x.flush();
               }
               catch(e:*)
               {
                  close();
               }
            }
         }
      }
      
      private function onConnect_internal(param1:*) : *
      {
         this.connecting = false;
         this.did_connect = true;
         this.tl = -1;
         this.onConnect();
      }
      
      private function onClose_internal(param1:*) : *
      {
         this.connecting = false;
         this.did_connect = false;
         if(this.hal)
         {
            this.hal = false;
            if(this.x != null)
            {
               this.x.removeEventListener(Event.CLOSE,this.onClose_internal);
               this.x.removeEventListener(Event.CONNECT,this.onConnect_internal);
               this.x.removeEventListener(ErrorEvent.ERROR,this.onError_internal);
               this.x.removeEventListener(IOErrorEvent.IO_ERROR,this.onError_internal);
               this.x.removeEventListener(ProgressEvent.SOCKET_DATA,this.onPartialData);
            }
         }
         this.onClose();
      }
      
      private function onError_internal(param1:*) : *
      {
         this.onError(param1);
         this.close();
      }
      
      private function onPartialData(param1:ProgressEvent) : *
      {
         var _loc2_:* = param1.target;
         var _loc3_:* = _loc2_.bytesAvailable;
         var _loc4_:int = 0;
         while(true)
         {
            _loc4_++;
            if(this.tl == -1)
            {
               if(_loc3_ >= this.hbc)
               {
                  if(this.hbc == 4)
                  {
                     this.tl = _loc2_.readUnsignedInt();
                     _loc3_ -= this.hbc;
                     addr61:
                     if(_loc3_ < this.tl)
                     {
                        break;
                     }
                     continue;
                  }
                  if(this.hbc == 2)
                  {
                     this.tl = _loc2_.readUnsignedShort();
                     _loc3_ -= this.hbc;
                     §§goto(addr61);
                  }
                  else
                  {
                     trace("wtf hbc " + this.hbc);
                  }
                  §§goto(addr61);
               }
               §§goto(addr104);
            }
            §§goto(addr61);
         }
         addr104:
      }
      
      public function forceCheckData() : *
      {
         var _loc1_:* = undefined;
         var _loc2_:int = 0;
         if(this.x != null)
         {
            _loc1_ = this.x.bytesAvailable;
            if(_loc1_ > 0)
            {
               _loc2_ = 0;
               while(true)
               {
                  _loc2_++;
                  if(this.tl == -1)
                  {
                     if(_loc1_ < this.hbc)
                     {
                        §§goto(addr116);
                     }
                     if(this.hbc == 4)
                     {
                        this.tl = this.x.readUnsignedInt();
                        _loc1_ -= this.hbc;
                     }
                     else if(this.hbc == 2)
                     {
                        this.tl = this.x.readUnsignedShort();
                        _loc1_ -= this.hbc;
                     }
                     else
                     {
                        trace("wtf hbc " + this.hbc);
                        §§goto(addr116);
                     }
                     §§goto(addr116);
                  }
                  if(_loc1_ < this.tl)
                  {
                     break;
                  }
                  if(this.ba.length < this.tl)
                  {
                     this.ba.length = this.tl;
                  }
                  if(this.tl > 0)
                  {
                     this.x.readBytes(this.ba,0,this.tl);
                  }
                  this.receive(this.ba,this.tl);
                  _loc1_ -= this.tl;
                  this.tl = -1;
               }
            }
         }
         addr116:
      }
   }
}
