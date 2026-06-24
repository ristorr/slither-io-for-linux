package starling.display.graphics
{
   import flash.geom.Point;
   import starling.display.Mesh;
   import starling.display.util.MathUtil;
   import starling.rendering.IndexData;
   import starling.rendering.VertexData;
   import starling.styles.MeshStyle;
   import starling.textures.Texture;
   
   public class EllipseMesh extends Mesh
   {
      
      protected static var __vertexData:VertexData;
      
      protected static var __indexData:IndexData;
      
      protected static var meshTexture:Texture;
      
      protected static var ratioX:Number = 1;
      
      protected static var ratioY:Number = 1;
      
      protected static var uvX:Number;
      
      protected static var uvY:Number;
      
      protected static var colAttr:String = "color";
      
      protected static var i:int;
      
      protected static var len:int;
      
      protected static var fX:Number;
      
      protected static var fY:Number;
      
      protected static var iNumVert:int;
      
      protected static var posAttr:String = "position";
      
      protected static var texAttr:String = "texCoords";
      
      protected static var iData:IndexData;
      
      protected static var vData:VertexData;
      
      protected static var ellipsePoint:Point = new Point();
      
      protected static var angleIncrement:Number;
      
      protected static var currentAngle:Number;
      
      protected static var halfSides:Number;
       
      
      protected var _sides:int;
      
      protected var _colour:uint;
      
      protected var _radiusX:Number;
      
      protected var _radiusY:Number;
      
      protected var _maxAngle:Number;
      
      protected var _reverse:Boolean;
      
      public function EllipseMesh(param1:int = 10, param2:Number = 100, param3:Number = 100, param4:uint = 0, param5:Texture = null, param6:Number = 6.283185307179586, param7:Boolean = false)
      {
         this._sides = param1;
         this._radiusX = param2;
         this._radiusY = param3;
         this._colour = param4;
         this._maxAngle = param6;
         this._reverse = param7;
         pixelSnapping = false;
         __vertexData = new VertexData(MeshStyle.VERTEX_FORMAT,this._sides + 2);
         __indexData = new IndexData(3 * this._sides);
         super(__vertexData,__indexData);
         this.texture = param5;
         this.updateVertices();
         vertexData.colorize(colAttr,this._colour,1,0,this._sides + 2);
         __vertexData = null;
         __indexData = null;
      }
      
      public function set radiusX(param1:Number) : void
      {
         if(this._radiusX != param1)
         {
            this._radiusX = param1;
            this.setRequiresRedraw();
         }
      }
      
      public function get radiusX() : Number
      {
         return this._radiusX;
      }
      
      public function set radiusY(param1:Number) : void
      {
         if(this._radiusY != param1)
         {
            this._radiusY = param1;
            this.setRequiresRedraw();
         }
      }
      
      public function get radiusY() : Number
      {
         return this._radiusY;
      }
      
      public function set maxAngle(param1:Number) : void
      {
         if(this._maxAngle != param1)
         {
            this._maxAngle = param1;
            this.setRequiresRedraw();
         }
      }
      
      public function get maxAngle() : Number
      {
         return this._maxAngle;
      }
      
      public function set reverse(param1:Boolean) : void
      {
         if(this._reverse != param1)
         {
            this._reverse = param1;
            this.setRequiresRedraw();
         }
      }
      
      public function get reverse() : Boolean
      {
         return this._reverse;
      }
      
      public function set colour(param1:uint) : void
      {
         if(this._colour != param1)
         {
            this._colour = param1;
            this.setRequiresRedraw();
         }
      }
      
      public function get colour() : uint
      {
         return this._colour;
      }
      
      override public function setRequiresRedraw() : void
      {
         vertexData.colorize(colAttr,this._colour,1,0,this._sides + 2);
         super.setRequiresRedraw();
      }
      
      override public function set texture(param1:Texture) : void
      {
         super.texture = param1;
         if(texture)
         {
            texture.setTexCoords(vertexData,0,texAttr,1,1);
         }
         this.setRequiresRedraw();
      }
      
      protected function updateVertices() : void
      {
         iNumVert = 0;
         vData = vertexData;
         meshTexture = texture;
         vData.setPoint(0,posAttr,0,0);
         ++iNumVert;
         halfSides = this._sides / 2;
         angleIncrement = this._maxAngle / this._sides;
         if(meshTexture)
         {
            ratioX = 1 / (this._radiusX * 2);
            ratioY = 1 / (this._radiusY * 2);
            meshTexture.setTexCoords(vData,0,texAttr,0.5,0.5);
         }
         if(this._reverse)
         {
            currentAngle = Math.PI * 2;
            i = 0;
            while(i <= this._sides)
            {
               MathUtil.calculateElipsePoint(this._radiusX,this._radiusY,currentAngle,ellipsePoint);
               if(currentAngle > Math.PI)
               {
                  ellipsePoint.y *= -1;
               }
               vData.setPoint(iNumVert,posAttr,ellipsePoint.x,ellipsePoint.y);
               if(meshTexture)
               {
                  if(ellipsePoint.x >= 0)
                  {
                     uvX = ellipsePoint.x * ratioX + 0.5;
                  }
                  else
                  {
                     uvX = 0.5 - Math.abs(ellipsePoint.x) * ratioX;
                  }
                  if(ellipsePoint.y >= 0)
                  {
                     uvY = ellipsePoint.y * ratioY + 0.5;
                  }
                  else
                  {
                     uvY = 0.5 - Math.abs(ellipsePoint.y) * ratioY;
                  }
                  meshTexture.setTexCoords(vData,iNumVert,texAttr,uvX,uvY);
               }
               ++iNumVert;
               ++i;
               currentAngle -= angleIncrement;
            }
         }
         else
         {
            currentAngle = 0;
            i = 0;
            while(i <= this._sides)
            {
               MathUtil.calculateElipsePoint(this._radiusX,this._radiusY,currentAngle,ellipsePoint);
               if(currentAngle > Math.PI)
               {
                  ellipsePoint.y *= -1;
               }
               vData.setPoint(iNumVert,posAttr,ellipsePoint.x,ellipsePoint.y);
               if(meshTexture)
               {
                  if(ellipsePoint.x >= 0)
                  {
                     uvX = ellipsePoint.x * ratioX + 0.5;
                  }
                  else
                  {
                     uvX = 0.5 - Math.abs(ellipsePoint.x) * ratioX;
                  }
                  if(ellipsePoint.y >= 0)
                  {
                     uvY = ellipsePoint.y * ratioY + 0.5;
                  }
                  else
                  {
                     uvY = 0.5 - Math.abs(ellipsePoint.y) * ratioY;
                  }
                  meshTexture.setTexCoords(vData,iNumVert,texAttr,uvX,uvY);
               }
               ++iNumVert;
               ++i;
               currentAngle += angleIncrement;
            }
         }
         iData = indexData;
         iData.numIndices = 0;
         vData.numVertices = iNumVert;
         i = 0;
         len = iNumVert - 2;
         while(i < len)
         {
            iData.addTriangle(0,i + 1,i + 2);
            ++i;
         }
         vData = null;
         iData = null;
      }
   }
}
