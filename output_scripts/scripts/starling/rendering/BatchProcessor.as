package starling.rendering
{
   import flash.geom.Matrix;
   import starling.display.Mesh;
   import starling.display.MeshBatch;
   import starling.utils.MeshSubset;
   
   internal class BatchProcessor
   {
      
      private static var sMeshSubset:MeshSubset = new MeshSubset();
       
      
      private var _batches:Vector.<MeshBatch>;
      
      private var _batchPool:BatchPool;
      
      private var _currentBatch:MeshBatch;
      
      private var _currentStyleType:Class;
      
      private var _onBatchComplete:Function;
      
      private var _cacheToken:starling.rendering.BatchToken;
      
      public function BatchProcessor()
      {
         super();
         this._batches = new Vector.<MeshBatch>(0);
         this._batchPool = new BatchPool();
         this._cacheToken = new starling.rendering.BatchToken();
      }
      
      public function dispose() : void
      {
         var _loc1_:MeshBatch = null;
         for each(_loc1_ in this._batches)
         {
            _loc1_.dispose();
         }
         this._batches.length = 0;
         this._batchPool.purge();
         this._currentBatch = null;
         this._onBatchComplete = null;
      }
      
      public function addMesh(param1:Mesh, param2:starling.rendering.RenderState, param3:MeshSubset = null, param4:Boolean = false) : void
      {
         var _loc5_:Matrix = null;
         var _loc6_:Number = NaN;
         if(param3 == null)
         {
            param3 = sMeshSubset;
            param3.vertexID = param3.indexID = 0;
            param3.numVertices = param1.numVertices;
            param3.numIndices = param1.numIndices;
         }
         else
         {
            if(param3.numVertices < 0)
            {
               param3.numVertices = param1.numVertices - param3.vertexID;
            }
            if(param3.numIndices < 0)
            {
               param3.numIndices = param1.numIndices - param3.indexID;
            }
         }
         if(param3.numVertices > 0)
         {
            if(this._currentBatch == null || !this._currentBatch.canAddMesh(param1,param3.numVertices))
            {
               this.finishBatch();
               this._currentStyleType = param1.style.type;
               this._currentBatch = this._batchPool.get(this._currentStyleType);
               this._currentBatch.blendMode = !!param2 ? param2.blendMode : param1.blendMode;
               this._cacheToken.setTo(this._batches.length);
               this._batches[this._batches.length] = this._currentBatch;
            }
            _loc5_ = !!param2 ? param2._modelviewMatrix : null;
            _loc6_ = !!param2 ? param2._alpha : 1;
            this._currentBatch.addMeshAt(param1,-1,-1,_loc5_,_loc6_,param3,param4);
            this._cacheToken.vertexID += param3.numVertices;
            this._cacheToken.indexID += param3.numIndices;
         }
      }
      
      public function finishBatch() : void
      {
         var _loc1_:MeshBatch = this._currentBatch;
         if(_loc1_)
         {
            this._currentBatch = null;
            this._currentStyleType = null;
            if(this._onBatchComplete != null)
            {
               this._onBatchComplete(_loc1_);
            }
         }
      }
      
      public function clear() : void
      {
         var _loc1_:int = int(this._batches.length);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            this._batchPool.put(this._batches[_loc2_]);
            _loc2_++;
         }
         this._batches.length = 0;
         this._currentBatch = null;
         this._currentStyleType = null;
         this._cacheToken.reset();
      }
      
      public function getBatchAt(param1:int) : MeshBatch
      {
         return this._batches[param1];
      }
      
      public function trim() : void
      {
         this._batchPool.purge();
      }
      
      public function fillToken(param1:starling.rendering.BatchToken) : starling.rendering.BatchToken
      {
         param1.batchID = this._cacheToken.batchID;
         param1.vertexID = this._cacheToken.vertexID;
         param1.indexID = this._cacheToken.indexID;
         return param1;
      }
      
      public function get numBatches() : int
      {
         return this._batches.length;
      }
      
      public function get onBatchComplete() : Function
      {
         return this._onBatchComplete;
      }
      
      public function set onBatchComplete(param1:Function) : void
      {
         this._onBatchComplete = param1;
      }
   }
}

import flash.utils.Dictionary;
import starling.display.MeshBatch;

class BatchPool
{
    
   
   private var _batchLists:Dictionary;
   
   public function BatchPool()
   {
      super();
      this._batchLists = new Dictionary();
   }
   
   public function purge() : void
   {
      var _loc1_:Array = null;
      var _loc2_:int = 0;
      for each(_loc1_ in this._batchLists)
      {
         _loc2_ = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc1_[_loc2_].dispose();
            _loc2_++;
         }
         _loc1_.length = 0;
      }
   }
   
   public function get(param1:Class) : MeshBatch
   {
      var _loc2_:Array = this._batchLists[param1];
      if(_loc2_ == null)
      {
         _loc2_ = [];
         this._batchLists[param1] = _loc2_;
      }
      if(_loc2_.length > 0)
      {
         return _loc2_.pop();
      }
      return new MeshBatch();
   }
   
   public function put(param1:MeshBatch) : void
   {
      var _loc2_:Class = param1.style.type;
      var _loc3_:Array = this._batchLists[_loc2_];
      if(_loc3_ == null)
      {
         _loc3_ = [];
         this._batchLists[_loc2_] = _loc3_;
      }
      param1.clear();
      _loc3_[_loc3_.length] = param1;
   }
}
