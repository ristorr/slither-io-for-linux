package starling.display.graphics
{
   import flash.geom.Point;
   import starling.display.Mesh;
   import starling.display.util.MathUtil;
   import starling.rendering.IndexData;
   import starling.rendering.VertexData;
   import starling.styles.MeshStyle;
   import starling.textures.Texture;
   
   public class RoundRectangleMesh extends Mesh
   {
      
      private static var __vertexData:VertexData;
      
      private static var __indexData:IndexData;
      
      private static var colAttr:String = "color";
      
      protected static var i:int;
      
      protected static var len:int;
      
      protected static var posAttr:String = "position";
      
      protected static var texAttr:String = "texCoords";
      
      protected static var vData:VertexData;
      
      protected static var iData:IndexData;
      
      protected static var anglePoint:Point = new Point();
      
      protected static var texturePoint:Point = new Point();
      
      protected static var angleIncrement:Number;
      
      protected static var currentAngle:Number;
      
      protected static var halfSides:Number;
      
      protected static var halfWidth:Number;
      
      protected static var halfHeight:Number;
      
      protected static var cornerRadiusStart:Point = new Point();
      
      protected static var cornerCenterX:Number;
      
      protected static var cornerCenterY:Number;
      
      protected static var meshTexture:Texture;
      
      protected static var ratioX:Number = 1;
      
      protected static var ratioY:Number = 1;
       
      
      protected var _rectangleWidth:Number;
      
      protected var _rectangleHeight:Number;
      
      protected var _cornerRadius:Number;
      
      protected var _cornerRadiusPrecision:Number;
      
      protected var _colour:uint;
      
      protected var verticeCount:int;
      
      public function RoundRectangleMesh(param1:Number = 100, param2:Number = 100, param3:Number = 25, param4:Number = 50, param5:uint = 0, param6:Texture = null)
      {
         this._rectangleWidth = param1;
         this._rectangleHeight = param2;
         this._cornerRadius = this.validateCornerRadius(param3);
         this._cornerRadiusPrecision = param4;
         this._colour = param5;
         pixelSnapping = true;
         __vertexData = new VertexData(MeshStyle.VERTEX_FORMAT,4 * this._cornerRadiusPrecision);
         __indexData = new IndexData(4 * this._cornerRadiusPrecision);
         super(__vertexData,__indexData);
         texture = param6;
         this.updateVertices();
         vertexData.colorize(colAttr,this._colour,1,0,-1);
         __vertexData = null;
         __indexData = null;
      }
      
      protected function validateCornerRadius(param1:Number) : Number
      {
         return Math.min(param1,Math.min(this._rectangleWidth,this._rectangleHeight) / 2);
      }
      
      public function set cornerRadius(param1:Number) : void
      {
         if(this._cornerRadius != param1)
         {
            this._cornerRadius = this.validateCornerRadius(param1);
            this.setRequiresRedraw();
         }
      }
      
      public function set cornerRadiusPrecision(param1:Number) : void
      {
         if(this._cornerRadiusPrecision != param1)
         {
            this._cornerRadiusPrecision = param1;
            this.setRequiresRedraw();
         }
      }
      
      public function set rectangleWidth(param1:Number) : void
      {
         if(this._rectangleWidth != param1)
         {
            this._rectangleWidth = param1;
            this.setRequiresRedraw();
         }
      }
      
      public function set rectangleHeight(param1:Number) : void
      {
         if(this._rectangleHeight != param1)
         {
            this._rectangleHeight = param1;
            this.setRequiresRedraw();
         }
      }
      
      public function set colour(param1:uint) : void
      {
         if(this._colour != param1)
         {
            this._colour = param1;
            this.setRequiresRedraw();
         }
      }
      
      override public function setRequiresRedraw() : void
      {
         vertexData.colorize(colAttr,this._colour,1,0,-1);
         super.setRequiresRedraw();
      }
      
      protected function updateVertices() : void
      {
         this.verticeCount = 0;
         vData = vertexData;
         halfWidth = this._rectangleWidth * 0.5;
         halfHeight = this._rectangleHeight * 0.5;
         cornerRadiusStart.x = halfWidth - this._cornerRadius;
         cornerRadiusStart.y = halfHeight - this._cornerRadius;
         vData.setPoint(0,posAttr,0,0);
         meshTexture = texture;
         if(meshTexture)
         {
            meshTexture.setTexCoords(vData,0,texAttr,0.5,0.5);
         }
         ++this.verticeCount;
         angleIncrement = 90 / this._cornerRadiusPrecision * MathUtil.DEG_TO_RAD;
         currentAngle = 0;
         if(meshTexture)
         {
            ratioX = 1 / this._rectangleWidth;
            ratioY = 1 / this._rectangleHeight;
         }
         i = 0;
         while(i < this._cornerRadiusPrecision)
         {
            MathUtil.calculateAnglePoint(cornerRadiusStart.x,cornerRadiusStart.y,this._cornerRadius,currentAngle,anglePoint);
            vData.setPoint(this.verticeCount,posAttr,anglePoint.x,anglePoint.y);
            if(meshTexture)
            {
               meshTexture.setTexCoords(vData,this.verticeCount,texAttr,anglePoint.x * ratioX + 0.5,anglePoint.y * ratioY + 0.5);
            }
            ++this.verticeCount;
            ++i;
            currentAngle += angleIncrement;
         }
         anglePoint.x = halfWidth - this._cornerRadius;
         anglePoint.y = halfHeight;
         vData.setPoint(this.verticeCount,posAttr,anglePoint.x,anglePoint.y);
         if(meshTexture)
         {
            meshTexture.setTexCoords(vData,this.verticeCount,texAttr,anglePoint.x * ratioX + 0.5,anglePoint.y * ratioY + 0.5);
         }
         ++this.verticeCount;
         cornerCenterX = cornerRadiusStart.x * -1;
         currentAngle = Math.PI / 2;
         i = 0;
         while(i < this._cornerRadiusPrecision)
         {
            MathUtil.calculateAnglePoint(cornerCenterX,cornerRadiusStart.y,this._cornerRadius,currentAngle,anglePoint);
            vData.setPoint(this.verticeCount,posAttr,anglePoint.x,anglePoint.y);
            if(meshTexture)
            {
               meshTexture.setTexCoords(vData,this.verticeCount,texAttr,0.5 - Math.abs(anglePoint.x) * ratioX,anglePoint.y * ratioY + 0.5);
            }
            ++this.verticeCount;
            ++i;
            currentAngle += angleIncrement;
         }
         anglePoint.x = halfWidth * -1;
         anglePoint.y = halfHeight - this._cornerRadius;
         vData.setPoint(this.verticeCount,posAttr,anglePoint.x,anglePoint.y);
         if(meshTexture)
         {
            meshTexture.setTexCoords(vData,this.verticeCount,texAttr,0.5 - Math.abs(anglePoint.x * ratioX),anglePoint.y * ratioY + 0.5);
         }
         ++this.verticeCount;
         cornerCenterY = cornerRadiusStart.y * -1;
         currentAngle = Math.PI;
         i = 0;
         while(i < this._cornerRadiusPrecision)
         {
            MathUtil.calculateAnglePoint(cornerCenterX,cornerCenterY,this._cornerRadius,currentAngle,anglePoint);
            vData.setPoint(this.verticeCount,posAttr,anglePoint.x,anglePoint.y);
            if(meshTexture)
            {
               meshTexture.setTexCoords(vData,this.verticeCount,texAttr,0.5 - Math.abs(anglePoint.x * ratioX),0.5 - Math.abs(anglePoint.y * ratioY));
            }
            ++this.verticeCount;
            ++i;
            currentAngle += angleIncrement;
         }
         vData.setPoint(this.verticeCount,posAttr,cornerCenterX,halfHeight * -1);
         if(meshTexture)
         {
            meshTexture.setTexCoords(vData,this.verticeCount,texAttr,0.5 - Math.abs(cornerCenterX * ratioX),0);
         }
         ++this.verticeCount;
         cornerCenterX = cornerRadiusStart.x;
         currentAngle = 270 * MathUtil.DEG_TO_RAD;
         i = 0;
         while(i < this._cornerRadiusPrecision)
         {
            MathUtil.calculateAnglePoint(cornerRadiusStart.x,cornerCenterY,this._cornerRadius,currentAngle,anglePoint);
            vData.setPoint(this.verticeCount,posAttr,anglePoint.x,anglePoint.y);
            if(meshTexture)
            {
               meshTexture.setTexCoords(vData,this.verticeCount,texAttr,anglePoint.x * ratioX + 0.5,0.5 - Math.abs(anglePoint.y * ratioY));
            }
            ++this.verticeCount;
            ++i;
            currentAngle += angleIncrement;
         }
         anglePoint.y = (halfHeight - this._cornerRadius) * -1;
         vData.setPoint(this.verticeCount,posAttr,halfWidth,anglePoint.y);
         if(meshTexture)
         {
            meshTexture.setTexCoords(vData,this.verticeCount,texAttr,1,0.5 - Math.abs(anglePoint.y * ratioY));
         }
         ++this.verticeCount;
         iData = indexData;
         iData.numIndices = 0;
         vData.numVertices = this.verticeCount;
         i = 0;
         len = this.verticeCount - 2;
         while(i < len)
         {
            iData.addTriangle(0,i + 1,i + 2);
            ++i;
         }
         iData.addTriangle(0,i + 1,1);
         vData = null;
         iData = null;
      }
   }
}
