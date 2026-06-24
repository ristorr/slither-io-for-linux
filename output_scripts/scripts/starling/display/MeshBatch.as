package starling.display
{
   import flash.geom.Matrix;
   import starling.rendering.IndexData;
   import starling.rendering.MeshEffect;
   import starling.rendering.Painter;
   import starling.rendering.VertexData;
   import starling.styles.MeshStyle;
   import starling.utils.MatrixUtil;
   import starling.utils.MeshSubset;
   
   public class MeshBatch extends Mesh
   {
      
      public static const MAX_NUM_VERTICES:int = 65535;
      
      private static var sFullMeshSubset:MeshSubset = new MeshSubset();
       
      
      private var _effect:MeshEffect;
      
      private var _batchable:Boolean;
      
      private var _vertexSyncRequired:Boolean;
      
      private var _indexSyncRequired:Boolean;
      
      public function MeshBatch()
      {
         var _loc1_:VertexData = new VertexData();
         var _loc2_:IndexData = new IndexData();
         super(_loc1_,_loc2_);
      }
      
      override public function dispose() : void
      {
         if(this._effect)
         {
            this._effect.dispose();
         }
         super.dispose();
      }
      
      override public function setVertexDataChanged() : void
      {
         this._vertexSyncRequired = true;
         super.setVertexDataChanged();
      }
      
      override public function setIndexDataChanged() : void
      {
         this._indexSyncRequired = true;
         super.setIndexDataChanged();
      }
      
      private function setVertexAndIndexDataChanged() : void
      {
         this._vertexSyncRequired = this._indexSyncRequired = true;
      }
      
      private function syncVertexBuffer() : void
      {
         this._effect.uploadVertexData(_vertexData);
         this._vertexSyncRequired = false;
      }
      
      private function syncIndexBuffer() : void
      {
         this._effect.uploadIndexData(_indexData);
         this._indexSyncRequired = false;
      }
      
      public function clear() : void
      {
         if(_parent)
         {
            setRequiresRedraw();
         }
         _vertexData.numVertices = 0;
         _indexData.numIndices = 0;
         this._vertexSyncRequired = true;
         this._indexSyncRequired = true;
      }
      
      public function addMesh(param1:Mesh, param2:Matrix = null, param3:Number = 1, param4:MeshSubset = null, param5:Boolean = false) : void
      {
         this.addMeshAt(param1,-1,-1,param2,param3,param4,param5);
      }
      
      public function addImage(param1:Mesh, param2:Matrix = null, param3:Number = 1, param4:MeshSubset = null, param5:Boolean = false) : void
      {
         this.addMeshAt(param1,-1,-1,param2,param1.alpha,param4,param5);
      }
      
      public function addMeshAt(param1:Mesh, param2:int = -1, param3:int = -1, param4:Matrix = null, param5:Number = 1, param6:MeshSubset = null, param7:Boolean = false) : void
      {
         if(param7)
         {
            param4 = null;
         }
         else if(param4 == null)
         {
            param4 = param1.transformationMatrix;
         }
         if(param6 == null)
         {
            param6 = sFullMeshSubset;
         }
         var _loc8_:int = int(_vertexData.numVertices);
         var _loc9_:int = param3 >= 0 ? param3 : _loc8_;
         var _loc10_:int = param2 >= 0 ? param2 : int(_indexData.numIndices);
         var _loc11_:MeshStyle = param1._style;
         if(_loc8_ == 0)
         {
            this.setupFor(param1);
         }
         _loc11_.batchVertexData(_style,_loc9_,param4,param6.vertexID,param6.numVertices);
         _loc11_.batchIndexData(_style,_loc10_,_loc9_ - param6.vertexID,param6.indexID,param6.numIndices);
         if(param5 != 1)
         {
            _vertexData.scaleAlphas("color",param5,_loc9_,param6.numVertices);
         }
         if(_parent)
         {
            setRequiresRedraw();
         }
         this._indexSyncRequired = this._vertexSyncRequired = true;
      }
      
      private function setupFor(param1:Mesh) : void
      {
         var _loc4_:MeshStyle = null;
         var _loc2_:MeshStyle = param1._style;
         var _loc3_:Class = _loc2_.type;
         if(_style.type != _loc3_)
         {
            (_loc4_ = new _loc3_() as MeshStyle).copyFrom(_loc2_);
            this.setStyle(_loc4_,false);
         }
         else
         {
            _style.copyFrom(_loc2_);
         }
      }
      
      public function canAddMesh(param1:Mesh, param2:int = -1) : Boolean
      {
         var _loc3_:int = int(_vertexData.numVertices);
         if(_loc3_ == 0)
         {
            return true;
         }
         if(param2 < 0)
         {
            param2 = param1.numVertices;
         }
         if(param2 == 0)
         {
            return true;
         }
         if(param2 + _loc3_ > MAX_NUM_VERTICES)
         {
            return false;
         }
         return _style.canBatchWith(param1._style);
      }
      
      override public function render(param1:Painter) : void
      {
         if(_vertexData.numVertices == 0)
         {
            return;
         }
         if(_pixelSnapping)
         {
            MatrixUtil.snapToPixels(param1.state.modelviewMatrix,param1.pixelSize);
         }
         if(this._batchable)
         {
            param1.batchMesh(this);
         }
         else
         {
            param1.finishMeshBatch();
            param1.drawCount += 1;
            param1.prepareToDraw();
            param1.excludeFromCache(this);
            if(this._vertexSyncRequired)
            {
               this.syncVertexBuffer();
            }
            if(this._indexSyncRequired)
            {
               this.syncIndexBuffer();
            }
            _style.updateEffect(this._effect,param1.state);
            this._effect.render(0,_indexData.numTriangles);
         }
      }
      
      override public function setStyle(param1:MeshStyle = null, param2:Boolean = true) : void
      {
         super.setStyle(param1,param2);
         if(this._effect)
         {
            this._effect.dispose();
         }
         this._effect = style.createEffect();
         this._effect.onRestore = this.setVertexAndIndexDataChanged;
         this.setVertexAndIndexDataChanged();
      }
      
      public function set numVertices(param1:int) : void
      {
         if(_vertexData.numVertices != param1)
         {
            _vertexData.numVertices = param1;
            this._vertexSyncRequired = true;
            setRequiresRedraw();
         }
      }
      
      public function set numIndices(param1:int) : void
      {
         if(_indexData.numIndices != param1)
         {
            _indexData.numIndices = param1;
            this._indexSyncRequired = true;
            setRequiresRedraw();
         }
      }
      
      public function get batchable() : Boolean
      {
         return this._batchable;
      }
      
      public function set batchable(param1:Boolean) : void
      {
         if(this._batchable != param1)
         {
            this._batchable = param1;
            setRequiresRedraw();
         }
      }
   }
}
