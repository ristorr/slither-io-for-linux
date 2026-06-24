package starling.display
{
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import starling.rendering.IndexData;
   import starling.rendering.VertexData;
   import starling.styles.MeshStyle;
   import starling.textures.Texture;
   import starling.utils.RectangleUtil;
   
   public class Quad extends Mesh
   {
      
      private static var sPoint3D:Vector3D = new Vector3D();
      
      private static var sMatrix:Matrix = new Matrix();
      
      private static var sMatrix3D:Matrix3D = new Matrix3D();
       
      
      private var _bounds:Rectangle;
      
      public function Quad(param1:Number, param2:Number, param3:uint = 16777215)
      {
         this._bounds = new Rectangle(0,0,param1,param2);
         var _loc4_:VertexData = new VertexData(MeshStyle.VERTEX_FORMAT,4);
         var _loc5_:IndexData = new IndexData(6);
         super(_loc4_,_loc5_);
         if(param1 == 0 || param2 == 0)
         {
            throw new ArgumentError("Invalid size: width and height must not be zero");
         }
         this.setupVertices();
         this.color = param3;
      }
      
      public static function fromTexture(param1:Texture) : Quad
      {
         var _loc2_:Quad = new Quad(100,100);
         _loc2_.texture = param1;
         _loc2_.readjustSize();
         return _loc2_;
      }
      
      protected function setupVertices() : void
      {
         var _loc1_:String = "position";
         var _loc2_:String = "texCoords";
         var _loc3_:Texture = style.texture;
         var _loc4_:VertexData = this.vertexData;
         var _loc5_:IndexData;
         (_loc5_ = this.indexData).numIndices = 0;
         _loc5_.addQuad(0,1,2,3);
         if(_loc4_.numVertices != 4)
         {
            _loc4_.numVertices = 4;
            _loc4_.trim();
         }
         if(_loc3_)
         {
            _loc3_.setupVertexPositions(_loc4_,0,"position",this._bounds);
            _loc3_.setupTextureCoordinates(_loc4_,0,_loc2_);
         }
         else
         {
            _loc4_.setPoint(0,_loc1_,this._bounds.left,this._bounds.top);
            _loc4_.setPoint(1,_loc1_,this._bounds.right,this._bounds.top);
            _loc4_.setPoint(2,_loc1_,this._bounds.left,this._bounds.bottom);
            _loc4_.setPoint(3,_loc1_,this._bounds.right,this._bounds.bottom);
            _loc4_.setPoint(0,_loc2_,0,0);
            _loc4_.setPoint(1,_loc2_,1,0);
            _loc4_.setPoint(2,_loc2_,0,1);
            _loc4_.setPoint(3,_loc2_,1,1);
         }
         setRequiresRedraw();
      }
      
      override public function getBounds(param1:DisplayObject, param2:Rectangle = null) : Rectangle
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(param2 == null)
         {
            param2 = new Rectangle();
         }
         if(param1 == this)
         {
            param2.copyFrom(this._bounds);
         }
         else if(param1 == parent && !isRotated)
         {
            _loc3_ = this.scaleX;
            _loc4_ = this.scaleY;
            param2.setTo(x - pivotX * _loc3_,y - pivotY * _loc4_,this._bounds.width * _loc3_,this._bounds.height * _loc4_);
            if(_loc3_ < 0)
            {
               param2.width *= -1;
               param2.x -= param2.width;
            }
            if(_loc4_ < 0)
            {
               param2.height *= -1;
               param2.y -= param2.height;
            }
         }
         else if(is3D && Boolean(stage))
         {
            stage.getCameraPosition(param1,sPoint3D);
            getTransformationMatrix3D(param1,sMatrix3D);
            RectangleUtil.getBoundsProjected(this._bounds,sMatrix3D,sPoint3D,param2);
         }
         else
         {
            getTransformationMatrix(param1,sMatrix);
            RectangleUtil.getBounds(this._bounds,sMatrix,param2);
         }
         return param2;
      }
      
      override public function hitTest(param1:Point) : DisplayObject
      {
         if(!visible || !touchable || !hitTestMask(param1))
         {
            return null;
         }
         if(this._bounds.containsPoint(param1))
         {
            return this;
         }
         return null;
      }
      
      public function readjustSize(param1:Number = -1, param2:Number = -1) : void
      {
         if(param1 <= 0)
         {
            param1 = !!texture ? texture.frameWidth : this._bounds.width;
         }
         if(param2 <= 0)
         {
            param2 = !!texture ? texture.frameHeight : this._bounds.height;
         }
         if(param1 != this._bounds.width || param2 != this._bounds.height)
         {
            this._bounds.setTo(0,0,param1,param2);
            this.setupVertices();
         }
      }
      
      override public function set texture(param1:Texture) : void
      {
         if(param1 != texture)
         {
            super.texture = param1;
            this.setupVertices();
         }
      }
   }
}
