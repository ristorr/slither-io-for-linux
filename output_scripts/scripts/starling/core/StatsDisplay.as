package starling.core
{
   import flash.geom.Rectangle;
   import flash.system.System;
   import starling.display.DisplayObject;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.EnterFrameEvent;
   import starling.events.Event;
   import starling.rendering.Painter;
   import starling.styles.MeshStyle;
   import starling.text.BitmapFont;
   import starling.text.TextField;
   import starling.utils.Align;
   
   internal class StatsDisplay extends Sprite
   {
      
      private static const UPDATE_INTERVAL:Number = 0.5;
      
      private static const B_TO_MB:Number = 1 / (1024 * 1024);
       
      
      private var _background:Quad;
      
      private var _labels:TextField;
      
      private var _values:TextField;
      
      private var _frameCount:int = 0;
      
      private var _totalTime:Number = 0;
      
      private var _fps:Number = 0;
      
      private var _memory:Number = 0;
      
      private var _gpuMemory:Number = 0;
      
      private var _drawCount:int = 0;
      
      private var _skipCount:int = 0;
      
      private var _showSkipped:Boolean = false;
      
      public function StatsDisplay()
      {
         super();
         var _loc1_:String = BitmapFont.MINI;
         var _loc2_:Number = BitmapFont.NATIVE_SIZE;
         var _loc3_:uint = 16777215;
         var _loc4_:Number = 90;
         var _loc5_:Number = 45;
         this._labels = new TextField(_loc4_,_loc5_);
         this._labels.format.setTo(_loc1_,_loc2_,_loc3_,Align.LEFT,Align.TOP);
         this._labels.batchable = true;
         this._labels.x = 2;
         this._values = new TextField(_loc4_ - 1,_loc5_,"");
         this._values.format.setTo(_loc1_,_loc2_,_loc3_,Align.RIGHT,Align.TOP);
         this._values.batchable = true;
         this._background = new Quad(_loc4_,_loc5_,0);
         this.updateLabels();
         if(this._background.style.type != MeshStyle)
         {
            this._background.style = new MeshStyle();
         }
         if(this._labels.style.type != MeshStyle)
         {
            this._labels.style = new MeshStyle();
         }
         if(this._values.style.type != MeshStyle)
         {
            this._values.style = new MeshStyle();
         }
         addChild(this._background);
         addChild(this._labels);
         addChild(this._values);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      private function onAddedToStage() : void
      {
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         starling.core.Starling.current.addEventListener(Event.SKIP_FRAME,this.onSkipFrame);
         this._totalTime = this._frameCount = this._skipCount = 0;
         this.update();
      }
      
      private function onRemovedFromStage() : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         starling.core.Starling.current.removeEventListener(Event.SKIP_FRAME,this.onSkipFrame);
      }
      
      private function onEnterFrame(param1:EnterFrameEvent) : void
      {
         this._totalTime += param1.passedTime;
         ++this._frameCount;
         if(this._totalTime > UPDATE_INTERVAL)
         {
            this.update();
            this._frameCount = this._skipCount = this._totalTime = 0;
         }
      }
      
      private function onSkipFrame() : void
      {
         this._skipCount += 1;
      }
      
      public function update() : void
      {
         this._background.color = this._skipCount > this._frameCount / 2 ? 16128 : 0;
         this._fps = this._totalTime > 0 ? this._frameCount / this._totalTime : 0;
         this._memory = System.totalMemory * B_TO_MB;
         this._gpuMemory = this.supportsGpuMem ? starling.core.Starling.context["totalGPUMemory"] * B_TO_MB : -1;
         var _loc1_:Number = this._totalTime > 0 ? this._skipCount / this._totalTime : 0;
         var _loc2_:String = this._showSkipped ? _loc1_.toFixed(_loc1_ < 100 ? 1 : 0) : "";
         var _loc3_:String = this._fps.toFixed(this._fps < 100 ? 1 : 0);
         var _loc4_:String = this._memory.toFixed(this._memory < 100 ? 1 : 0);
         var _loc5_:String = this._gpuMemory.toFixed(this._gpuMemory < 100 ? 1 : 0);
         var _loc6_:String = String((this._totalTime > 0 ? this._drawCount - 2 : this._drawCount).toString());
         this._values.text = _loc3_ + "\n" + (this._showSkipped ? _loc2_ + "\n" : "") + _loc4_ + "\n" + (this._gpuMemory >= 0 ? _loc5_ + "\n" : "") + _loc6_;
      }
      
      private function updateLabels() : void
      {
         var _loc1_:Array = ["frames/sec:"];
         if(this._showSkipped)
         {
            _loc1_.insertAt(_loc1_.length,"skipped/sec:");
         }
         _loc1_.insertAt(_loc1_.length,"std memory:");
         if(this.supportsGpuMem)
         {
            _loc1_.insertAt(_loc1_.length,"gpu memory:");
         }
         _loc1_.insertAt(_loc1_.length,"draw calls:");
         this._labels.text = _loc1_.join("\n");
         this._background.height = this._labels.textBounds.height + 4;
      }
      
      override public function render(param1:Painter) : void
      {
         param1.excludeFromCache(this);
         param1.finishMeshBatch();
         super.render(param1);
      }
      
      override public function getBounds(param1:DisplayObject, param2:flash.geom.Rectangle = null) : flash.geom.Rectangle
      {
         return this._background.getBounds(param1,param2);
      }
      
      private function get supportsGpuMem() : Boolean
      {
         return "totalGPUMemory" in starling.core.Starling.context;
      }
      
      public function get drawCount() : int
      {
         return this._drawCount;
      }
      
      public function set drawCount(param1:int) : void
      {
         this._drawCount = param1;
      }
      
      public function get fps() : Number
      {
         return this._fps;
      }
      
      public function set fps(param1:Number) : void
      {
         this._fps = param1;
      }
      
      public function get memory() : Number
      {
         return this._memory;
      }
      
      public function set memory(param1:Number) : void
      {
         this._memory = param1;
      }
      
      public function get gpuMemory() : Number
      {
         return this._gpuMemory;
      }
      
      public function set gpuMemory(param1:Number) : void
      {
         this._gpuMemory = param1;
      }
      
      public function get showSkipped() : Boolean
      {
         return this._showSkipped;
      }
      
      public function set showSkipped(param1:Boolean) : void
      {
         this._showSkipped = param1;
         this.updateLabels();
         this.update();
      }
   }
}
