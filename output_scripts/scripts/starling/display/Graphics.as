package starling.display
{
   import flash.geom.Matrix;
   import flash.geom.Point;
   import starling.display.graphics.EllipseMesh;
   import starling.display.graphics.Fill;
   import starling.display.graphics.NGon;
   import starling.display.graphics.RoundRectangleMesh;
   import starling.display.graphics.RoundedRectangle;
   import starling.display.graphics.Stroke;
   import starling.display.materials.IMaterial;
   import starling.display.util.CurveUtil;
   import starling.textures.Texture;
   
   public class Graphics
   {
      
      protected static const BEZIER_ERROR:Number = 0.75;
      
      private static var numSides:int;
      
      private static var ellipseMatrix:Matrix = new Matrix();
      
      private static var nGon:NGon;
      
      private static var anglePerSide:Number;
      
      private static var i:int;
      
      private static var anglePoint:Point = new Point();
      
      private static var ellipsePoint:Point = new Point();
      
      private static var currentAngle:Number;
      
      private static var _storedFill:Fill;
      
      private static var ellipseMesh:EllipseMesh;
      
      private static var doublePI:Number = Math.PI * 2;
      
      private static var halfPI:Number = Math.PI / 2;
      
      private static var threeQuarterCircle:Number = Math.PI / 2 + halfPI;
      
      private static var ellipseX:Number;
      
      private static var ellipseY:Number;
      
      private static var minimumStrokeThickness:Number;
      
      private static var drawCircleAlign:Boolean;
      
      private static var halfThickness:Number;
      
      private static var rectangleQuad:starling.display.Quad;
      
      private static var storedFill:Fill;
      
      private static var storedIsFillSet:Boolean;
      
      private static var strokePoints:Vector.<Number>;
      
      private static var roundRectangleMesh:RoundRectangleMesh;
       
      
      protected var _container:starling.display.DisplayObjectContainer;
      
      protected var _penPosX:Number;
      
      protected var _penPosY:Number;
      
      protected var _currentFill:Fill;
      
      protected var _fillStyleSet:Boolean;
      
      protected var _fillColor:uint;
      
      protected var _fillAlpha:Number;
      
      protected var _fillTexture:Texture;
      
      protected var _fillMaterial:IMaterial;
      
      protected var _fillMatrix:Matrix;
      
      protected var _fillDrawInBack:Boolean;
      
      protected var _currentStroke:Stroke;
      
      protected var _strokeStyleSet:Boolean;
      
      protected var _strokeThickness:Number;
      
      protected var _strokeColor:uint;
      
      protected var _strokeAlpha:Number;
      
      protected var _strokeTexture:Texture;
      
      protected var _strokeMaterial:IMaterial;
      
      protected var _strokeDrawInBack:Boolean;
      
      protected var _strokeJointType:int;
      
      protected var _enableStrokeLineThicknessChange:Boolean;
      
      protected var _strokeLineThicknessChangeRatio:Number;
      
      protected var _precisionHitTest:Boolean = false;
      
      protected var _precisionHitTestDistance:Number = 0;
      
      protected var _boundsBuffer:Number = 0;
      
      protected var _boundsBufferX:Number = 0;
      
      protected var _boundsBufferY:Number = 0;
      
      protected var _pauseStroke:Boolean;
      
      protected var _pauseFill:Boolean;
      
      private var roundedRect:RoundedRectangle;
      
      private var m:Matrix;
      
      public function Graphics()
      {
         super();
         this.roundedRect = new RoundedRectangle(100,100,25,25,25,25,10);
      }
      
      public static function calculateAnglePoint(param1:Number, param2:Number, param3:Number, param4:Number, param5:Point) : void
      {
         param5.x = param1 + param3 * Math.cos(param4);
         param5.y = param2 + param3 * Math.sin(param4);
      }
      
      public function get container() : starling.display.DisplayObjectContainer
      {
         return this._container;
      }
      
      public function set container(param1:starling.display.DisplayObjectContainer) : void
      {
         this._container = param1;
      }
      
      public function get boundsBuffer() : Number
      {
         return this._boundsBuffer;
      }
      
      public function set boundsBuffer(param1:Number) : void
      {
         this._boundsBuffer = param1;
         this._boundsBufferX = param1;
         this._boundsBufferY = param1;
      }
      
      public function get boundsBufferX() : Number
      {
         return this._boundsBufferX;
      }
      
      public function set boundsBufferX(param1:Number) : void
      {
         this._boundsBufferX = param1;
      }
      
      public function get boundsBufferY() : Number
      {
         return this._boundsBufferY;
      }
      
      public function set boundsBufferY(param1:Number) : void
      {
         this._boundsBufferY = param1;
      }
      
      public function get strokeColor() : uint
      {
         return this._strokeColor;
      }
      
      public function get strokeTexture() : Texture
      {
         return this._strokeTexture;
      }
      
      public function get strokeThickness() : Number
      {
         return this._strokeThickness;
      }
      
      public function get isFillStyleSet() : Boolean
      {
         return this._fillStyleSet;
      }
      
      public function get fillColor() : uint
      {
         return this._fillColor;
      }
      
      public function get fillAlpha() : Number
      {
         return this._fillAlpha;
      }
      
      public function get fillTexture() : Texture
      {
         return this._fillTexture;
      }
      
      public function get penPositionX() : Number
      {
         return this._penPosX;
      }
      
      public function get penPositionY() : Number
      {
         return this._penPosY;
      }
      
      public function get strokeStyleSet() : Boolean
      {
         return this._strokeStyleSet;
      }
      
      public function set pauseStroke(param1:Boolean) : void
      {
         this._pauseStroke = param1;
      }
      
      public function get pauseStroke() : Boolean
      {
         return this._pauseStroke;
      }
      
      public function set pauseFill(param1:Boolean) : void
      {
         this._pauseFill = param1;
      }
      
      public function get pauseFill() : Boolean
      {
         return this._pauseFill;
      }
      
      public function set enableStrokeLineThicknessChange(param1:Boolean) : void
      {
         this._enableStrokeLineThicknessChange = param1;
      }
      
      public function get enableStrokeLineThicknessChange() : Boolean
      {
         return this._enableStrokeLineThicknessChange;
      }
      
      public function set strokeLineThicknessChangeRatio(param1:Number) : void
      {
         this._strokeLineThicknessChangeRatio = param1;
      }
      
      public function get strokeLineThicknessChangeRatio() : Number
      {
         return this._strokeLineThicknessChangeRatio;
      }
      
      public function clear() : void
      {
         this._enableStrokeLineThicknessChange = false;
         this._strokeLineThicknessChangeRatio = 0;
         this._penPosX = NaN;
         this._penPosY = NaN;
         this.endStroke();
         this.endFill();
         this._container.removeChildren(0,-1,true);
      }
      
      public function beginFill(param1:uint, param2:Number = 1, param3:Boolean = false) : starling.display.Graphics
      {
         this.endFill();
         this._fillStyleSet = true;
         this._fillColor = param1;
         this._fillAlpha = param2;
         this._fillTexture = null;
         this._fillMaterial = null;
         this._fillMatrix = null;
         this._fillDrawInBack = param3;
         return this;
      }
      
      public function beginTextureFill(param1:Texture, param2:Matrix = null, param3:uint = 16777215, param4:Number = 1, param5:Boolean = false) : starling.display.Graphics
      {
         this.endFill();
         this._fillStyleSet = true;
         this._fillColor = param3;
         this._fillAlpha = param4;
         this._fillTexture = param1;
         this._fillMaterial = null;
         this._fillMatrix = new Matrix();
         this._fillDrawInBack = param5;
         if(param2)
         {
            this._fillMatrix = param2.clone();
            this._fillMatrix.invert();
         }
         else
         {
            this._fillMatrix = new Matrix();
         }
         this._fillMatrix.scale(1 / param1.width,1 / param1.height);
         return this;
      }
      
      public function beginMaterialFill(param1:IMaterial, param2:Matrix = null) : starling.display.Graphics
      {
         this.endFill();
         this._fillStyleSet = true;
         this._fillColor = 16777215;
         this._fillAlpha = 1;
         this._fillTexture = null;
         this._fillMaterial = param1;
         if(param2)
         {
            this._fillMatrix = param2.clone();
            this._fillMatrix.invert();
         }
         else
         {
            this._fillMatrix = new Matrix();
         }
         return this;
      }
      
      public function endFill() : void
      {
         this._fillStyleSet = false;
         this._fillColor = NaN;
         this._fillAlpha = NaN;
         this._fillTexture = null;
         this._fillMaterial = null;
         this._fillMatrix = null;
         this._fillDrawInBack = false;
         this._pauseFill = false;
         if(Boolean(this._currentFill) && this._currentFill.numVertices < 3)
         {
            this._currentFill.removeFromParent(true);
         }
         this._currentFill = null;
      }
      
      public function lineStyle(param1:Number = NaN, param2:uint = 0, param3:Number = 1, param4:int = 2, param5:Boolean = false) : starling.display.Graphics
      {
         this.endStroke();
         this._strokeStyleSet = !isNaN(param1) && param1 > 0;
         this._strokeThickness = param1;
         this._strokeColor = param2;
         this._strokeAlpha = param3;
         this._strokeTexture = null;
         this._strokeMaterial = null;
         this._strokeJointType = param4;
         this._strokeDrawInBack = param5;
         return this;
      }
      
      public function lineTexture(param1:Number = NaN, param2:Texture = null, param3:Number = 16777215, param4:Number = 1, param5:int = 2, param6:Boolean = false) : starling.display.Graphics
      {
         this.endStroke();
         this._strokeStyleSet = !isNaN(param1) && param1 > 0 && Boolean(param2);
         this._strokeThickness = param1;
         this._strokeColor = param3;
         this._strokeAlpha = param4;
         this._strokeTexture = param2;
         this._strokeMaterial = null;
         this._strokeJointType = param5;
         this._strokeDrawInBack = param6;
         return this;
      }
      
      public function lineMaterial(param1:Number = NaN, param2:IMaterial = null) : starling.display.Graphics
      {
         this.endStroke();
         this._strokeStyleSet = !isNaN(param1) && param1 > 0 && Boolean(param2);
         this._strokeThickness = param1;
         this._strokeColor = 16777215;
         this._strokeAlpha = 1;
         this._strokeTexture = null;
         this._strokeMaterial = param2;
         return this;
      }
      
      public function endStroke() : void
      {
         this._strokeStyleSet = false;
         this._strokeThickness = NaN;
         this._strokeColor = NaN;
         this._strokeAlpha = NaN;
         this._strokeTexture = null;
         this._strokeMaterial = null;
         this._pauseStroke = false;
         if(Boolean(this._currentStroke) && this._currentStroke.numVertices < 2)
         {
            this._currentStroke.removeFromParent(true);
            this._penPosX = NaN;
            this._penPosY = NaN;
         }
         this._currentStroke = null;
      }
      
      public function moveTo(param1:Number, param2:Number) : starling.display.Graphics
      {
         if(this._strokeStyleSet)
         {
            if(!this._currentStroke)
            {
               this.createStroke();
            }
            if(this._currentStroke.numVertices == 0)
            {
               this._currentStroke.addVertex(param1,param2,this._strokeThickness);
            }
            else
            {
               this._currentStroke.addDegenerates(param1,param2);
            }
         }
         if(this._fillStyleSet)
         {
            if(!this._currentFill)
            {
               this.createFill();
               this._currentFill.addVertex(param1,param2);
            }
            else if(this._currentFill.numVertices == 0)
            {
               this._currentFill.addVertex(param1,param2);
            }
            else
            {
               this._currentFill.addDegenerates(param1,param2);
            }
         }
         if(this._strokeStyleSet && this._currentStroke || this._fillStyleSet && this._currentFill)
         {
            this._penPosX = param1;
            this._penPosY = param2;
         }
         return this;
      }
      
      public function lineMoveToFillTo(param1:Number, param2:Number, param3:Number, param4:Number) : starling.display.Graphics
      {
         if(this._strokeStyleSet)
         {
            if(!this._currentStroke)
            {
               this.createStroke();
            }
            if(this._currentStroke.numVertices == 0)
            {
               this._currentStroke.addVertex(param1,param2,this._strokeThickness);
            }
            else
            {
               this._currentStroke.addDegenerates(param1,param2);
            }
         }
         if(this._fillStyleSet)
         {
            if(!this._currentFill)
            {
               this.createFill();
               this._currentFill.addVertex(param3,param4);
            }
            else
            {
               this._currentFill.addDegenerates(param3,param4);
            }
         }
         this._penPosX = param1;
         this._penPosY = param2;
         return this;
      }
      
      public function lineTo(param1:Number, param2:Number, param3:Boolean = false) : starling.display.Graphics
      {
         if(this._penPosX != this._penPosX || this._penPosY != this._penPosY)
         {
            this.moveTo(0,0);
         }
         if(this._strokeStyleSet)
         {
            if(!this._currentStroke)
            {
               this.createStroke();
            }
            this._currentStroke.lineTo(param1,param2,this._strokeThickness);
            if(this._enableStrokeLineThicknessChange && !param3)
            {
               this._strokeThickness += this._strokeLineThicknessChangeRatio;
               if(this._strokeThickness <= 0)
               {
                  this._strokeThickness = 0.5;
               }
            }
         }
         if(this._fillStyleSet)
         {
            if(this._currentFill == null)
            {
               this.createFill();
            }
            this._currentFill.addVertex(param1,param2);
         }
         this._penPosX = param1;
         this._penPosY = param2;
         return this;
      }
      
      public function lineToFillTo(param1:Number, param2:Number, param3:Number, param4:Number, param5:Boolean = false) : starling.display.Graphics
      {
         if(this._penPosX != this._penPosX || this._penPosY != this._penPosY)
         {
            this.moveTo(0,0);
         }
         if(this._strokeStyleSet)
         {
            if(this._currentStroke == null)
            {
               this.createStroke();
            }
            this._currentStroke.lineTo(param1,param2,this._strokeThickness);
            if(this._enableStrokeLineThicknessChange && !param5)
            {
               this._strokeThickness += this._strokeLineThicknessChangeRatio;
               if(this._strokeThickness <= 0)
               {
                  this._strokeThickness = 0.5;
               }
            }
         }
         if(this._fillStyleSet)
         {
            if(this._currentFill == null)
            {
               this.createFill();
            }
            this._currentFill.addVertex(param3,param4);
         }
         this._penPosX = param1;
         this._penPosY = param2;
         return this;
      }
      
      public function curveTo(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number = 0.75) : starling.display.Graphics
      {
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc6_:Number = this._penPosX;
         var _loc7_:Number = this._penPosY;
         if(isNaN(_loc6_))
         {
            _loc6_ = 0;
            _loc7_ = 0;
         }
         var _loc8_:Vector.<Number>;
         var _loc9_:int = int((_loc8_ = CurveUtil.quadraticCurve(_loc6_,_loc7_,param1,param2,param3,param4,param5)).length);
         var _loc10_:int = 0;
         while(_loc10_ < _loc9_)
         {
            _loc11_ = _loc8_[_loc10_];
            _loc12_ = _loc8_[_loc10_ + 1];
            if(_loc10_ == 0 && isNaN(this._penPosX))
            {
               this.moveTo(_loc11_,_loc12_);
            }
            else
            {
               this.lineTo(_loc11_,_loc12_);
            }
            _loc10_ += 2;
         }
         this._penPosX = param3;
         this._penPosY = param4;
         return this;
      }
      
      public function cubicCurveTo(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number = 0.75) : starling.display.Graphics
      {
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc8_:Number = this._penPosX;
         var _loc9_:Number = this._penPosY;
         if(isNaN(_loc8_))
         {
            _loc8_ = 0;
            _loc9_ = 0;
         }
         var _loc10_:Vector.<Number>;
         var _loc11_:int = int((_loc10_ = CurveUtil.cubicCurve(_loc8_,_loc9_,param1,param2,param3,param4,param5,param6,param7)).length);
         var _loc12_:int = 0;
         while(_loc12_ < _loc11_)
         {
            _loc13_ = _loc10_[_loc12_];
            _loc14_ = _loc10_[_loc12_ + 1];
            if(_loc12_ == 0 && isNaN(this._penPosX))
            {
               this.moveTo(_loc13_,_loc14_);
            }
            else
            {
               this.lineTo(_loc13_,_loc14_);
            }
            _loc12_ += 2;
         }
         this._penPosX = param5;
         this._penPosY = param6;
         return this;
      }
      
      public function drawCircle(param1:Number, param2:Number, param3:Number, param4:Number = 10) : starling.display.Graphics
      {
         this.drawEllipse(param1,param2,param3,param3,param4);
         return this;
      }
      
      public function drawEllipse(param1:Number, param2:Number, param3:Number, param4:Number, param5:uint = 0, param6:Number = 6.283185307179586, param7:Boolean = false, param8:Number = 0) : starling.display.Graphics
      {
         if(param5 == 0)
         {
            numSides = Math.PI * (param3 * 0.5 + param4 * 0.5) * 0.25;
            numSides = numSides < 6 ? 6 : numSides;
         }
         else
         {
            numSides = param5;
         }
         if(this._fillStyleSet && !this._pauseFill)
         {
            ellipseMesh = new EllipseMesh(param5,param3,param4,this._fillColor,this._fillTexture,param6,param7);
            ellipseMesh.x = param1;
            ellipseMesh.y = param2;
            ellipseMesh.rotation = param8;
            ellipseMesh.alpha = this._fillAlpha;
            if(this._fillDrawInBack)
            {
               this._container.addChildAt(ellipseMesh,0);
            }
            else
            {
               this._container.addChild(ellipseMesh);
            }
         }
         if(this._strokeStyleSet && !this._pauseStroke)
         {
            _storedFill = this._currentFill;
            this._currentFill = null;
            anglePerSide = param6 / numSides;
            currentAngle = anglePerSide;
            CurveUtil.calculateAnglePoint(param1,param2,param3,param8,anglePoint);
            this.moveTo(anglePoint.x,anglePoint.y);
            minimumStrokeThickness = this._strokeThickness * 0.2;
            drawCircleAlign = this._strokeThickness / anglePerSide < 500;
            if(param7)
            {
               if(drawCircleAlign)
               {
                  if(param8 == 0)
                  {
                     anglePoint.y = param2 - minimumStrokeThickness;
                  }
                  else
                  {
                     CurveUtil.calculateAnglePoint(param1,param2,param3,param8 - 0.0001745329,anglePoint);
                  }
                  this.lineTo(anglePoint.x,anglePoint.y);
               }
               currentAngle = Math.PI * 2 - anglePerSide;
               i = 0;
               while(i < numSides)
               {
                  ellipseX = Math.cos(currentAngle) * param3;
                  ellipseY = CurveUtil.calculateElipseY(param3,param4,ellipseX);
                  if(currentAngle < Math.PI)
                  {
                     ellipseY *= -1;
                  }
                  anglePoint.x = ellipseX * Math.cos(param8) + ellipseY * Math.sin(param8);
                  anglePoint.y = ellipseX * Math.sin(param8) - ellipseY * Math.cos(param8);
                  if(drawCircleAlign && currentAngle < anglePerSide && currentAngle < threeQuarterCircle)
                  {
                     this.lineTo(anglePoint.x + param1 - minimumStrokeThickness * Math.sin(param8 + param6),anglePoint.y + param2 + minimumStrokeThickness * Math.cos(param8 + param6));
                  }
                  this.lineTo(anglePoint.x + param1,anglePoint.y + param2);
                  ++i;
                  currentAngle -= anglePerSide;
               }
            }
            else
            {
               if(drawCircleAlign)
               {
                  if(param8 == 0)
                  {
                     anglePoint.y = param2 + minimumStrokeThickness;
                  }
                  else
                  {
                     CurveUtil.calculateAnglePoint(param1,param2,param3,param8 + 0.0001745329,anglePoint);
                  }
                  this.lineTo(anglePoint.x,anglePoint.y);
               }
               currentAngle = anglePerSide;
               i = 0;
               while(i < numSides)
               {
                  ellipseX = Math.cos(currentAngle) * param3;
                  ellipseY = CurveUtil.calculateElipseY(param3,param4,ellipseX);
                  if(currentAngle < Math.PI)
                  {
                     ellipseY *= -1;
                  }
                  anglePoint.x = ellipseX * Math.cos(param8) + ellipseY * Math.sin(param8);
                  anglePoint.y = ellipseX * Math.sin(param8) - ellipseY * Math.cos(param8);
                  if(drawCircleAlign && currentAngle > param6 - anglePerSide && currentAngle > halfPI)
                  {
                     this.lineTo(anglePoint.x + param1 + minimumStrokeThickness * Math.sin(param8 + param6),anglePoint.y + param2 - minimumStrokeThickness * Math.cos(param8 + param6));
                  }
                  this.lineTo(anglePoint.x + param1,anglePoint.y + param2);
                  ++i;
                  currentAngle += anglePerSide;
               }
            }
            this._currentFill = _storedFill;
         }
         return this;
      }
      
      public function drawRect(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number = 0, param6:Boolean = false) : starling.display.Graphics
      {
         if(this._fillStyleSet && !this._pauseFill)
         {
            rectangleQuad = new starling.display.Quad(param3,param4,this._fillColor);
            if(param6)
            {
               rectangleQuad.alignPivot();
            }
            rectangleQuad.x = param1 + rectangleQuad.pivotX;
            rectangleQuad.y = param2 + rectangleQuad.pivotY;
            rectangleQuad.alpha = this._fillAlpha;
            rectangleQuad.rotation = param5;
            if(this._fillTexture)
            {
               rectangleQuad.texture = this._fillTexture;
            }
            if(this._fillDrawInBack)
            {
               this._container.addChildAt(rectangleQuad,0);
            }
            else
            {
               this._container.addChild(rectangleQuad);
            }
         }
         if(this._strokeStyleSet && !this._pauseStroke)
         {
            _storedFill = this._currentFill;
            this._currentFill = null;
            halfThickness = this._strokeThickness / 2;
            this.moveTo(param1 - halfThickness,param2);
            this.lineTo(param1 + param3,param2);
            this.lineTo(param1 + param3,param2 + param4);
            this.lineTo(param1,param2 + param4);
            this.lineTo(param1,param2 + halfThickness);
            this._currentFill = _storedFill;
         }
         return this;
      }
      
      public function drawRoundRect(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:uint = 20, param7:Number = 0) : starling.display.Graphics
      {
         this.drawRoundRectComplex(param1,param2,param3,param4,param5,param5,param5,param5,param6,param7);
         return this;
      }
      
      public function drawRoundRectComplex(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number, param9:uint, param10:Number = 0) : starling.display.Graphics
      {
         if(this._fillStyleSet && !this._pauseFill)
         {
            roundRectangleMesh = new RoundRectangleMesh(param3,param4,param5,param9,this._fillColor,this._fillTexture);
            roundRectangleMesh.x = param1 + param3 * 0.5;
            roundRectangleMesh.y = param2 + param4 * 0.5;
            roundRectangleMesh.alpha = this._fillAlpha;
            roundRectangleMesh.rotation = param10;
            if(this._fillDrawInBack)
            {
               this._container.addChildAt(roundRectangleMesh,0);
            }
            else
            {
               this._container.addChild(roundRectangleMesh);
            }
         }
         if(this._strokeStyleSet && !this._pauseStroke)
         {
            storedFill = this._currentFill;
            storedIsFillSet = this._fillStyleSet;
            this._currentFill = null;
            this._fillStyleSet = false;
            this.roundedRect.width = param3;
            this.roundedRect.height = param4;
            this.roundedRect.topLeftRadius = param5;
            this.roundedRect.topRightRadius = param6;
            this.roundedRect.bottomLeftRadius = param7;
            this.roundedRect.bottomRightRadius = param8;
            this.roundedRect.radiusPrecision = param9;
            this.m = new Matrix();
            this.m.scale(param3,param4);
            if(this._fillMatrix)
            {
               this.m.concat(this._fillMatrix);
            }
            this.roundedRect.uvMatrix = this.m;
            this.roundedRect.x = param1;
            this.roundedRect.y = param2;
            strokePoints = this.roundedRect.getStrokePoints();
            i = 0;
            while(i < strokePoints.length)
            {
               if(i == 0)
               {
                  this.moveTo(param1 + strokePoints[i],param2 + strokePoints[i + 1]);
               }
               else
               {
                  this.lineTo(param1 + strokePoints[i],param2 + strokePoints[i + 1]);
               }
               i += 2;
            }
            this._currentFill = storedFill;
            this._fillStyleSet = storedIsFillSet;
         }
         return this;
      }
      
      public function set precisionHitTest(param1:Boolean) : void
      {
         this._precisionHitTest = param1;
         if(this._currentFill)
         {
            this._currentFill.precisionHitTest = param1;
         }
         if(this._currentStroke)
         {
            this._currentStroke.precisionHitTest = param1;
         }
      }
      
      public function get precisionHitTest() : Boolean
      {
         return this._precisionHitTest;
      }
      
      public function set precisionHitTestDistance(param1:Number) : void
      {
         this._precisionHitTestDistance = param1;
         if(this._currentFill)
         {
            this._currentFill.precisionHitTestDistance = param1;
         }
         if(this._currentStroke)
         {
            this._currentStroke.precisionHitTestDistance = param1;
         }
      }
      
      public function get precisionHitTestDistance() : Number
      {
         return this._precisionHitTestDistance;
      }
      
      protected function createStrokeInstance() : Stroke
      {
         return new Stroke();
      }
      
      protected function createFillInstance() : Fill
      {
         return new Fill();
      }
      
      public function get currentStroke() : Stroke
      {
         return this._currentStroke;
      }
      
      public function get currentFill() : Fill
      {
         return this._currentFill;
      }
      
      protected function createStroke() : void
      {
         if(this._currentStroke != null)
         {
            throw new Error("Current stroke should be disposed via endStroke() first.");
         }
         this._currentStroke = this.createStrokeInstance();
         this._currentStroke.precisionHitTest = this._precisionHitTest;
         this._currentStroke.precisionHitTestDistance = this._precisionHitTestDistance;
         this._currentStroke.boundsBufferX = this._boundsBufferX;
         this._currentStroke.boundsBufferY = this._boundsBufferY;
         if(this._strokeMaterial)
         {
            this._currentStroke.material = this._strokeMaterial;
         }
         else if(this._strokeTexture)
         {
            this._currentStroke.material.texture = this._strokeTexture;
         }
         this._currentStroke.material.color = this._strokeColor;
         this._currentStroke.material.alpha = this._strokeAlpha;
         if(this._strokeDrawInBack)
         {
            this._container.addChildAt(this._currentStroke,0);
         }
         else
         {
            this._container.addChild(this._currentStroke);
         }
         if(this._penPosX == this._penPosX && this._penPosY == this._penPosY)
         {
            this._currentStroke.addVertex(this._penPosX,this._penPosY,this._strokeThickness);
         }
         this._currentStroke.jointType = this._strokeJointType;
      }
      
      protected function createFill() : void
      {
         if(this._currentFill != null)
         {
            throw new Error("Current stroke should be disposed via endFill() first.");
         }
         this._currentFill = this.createFillInstance();
         this._currentFill.boundsBufferX = this._boundsBufferX;
         this._currentFill.boundsBufferY = this._boundsBufferY;
         if(this._fillMatrix)
         {
            this._currentFill.uvMatrix = this._fillMatrix;
         }
         this._currentFill.precisionHitTest = this._precisionHitTest;
         this._currentFill.precisionHitTestDistance = this._precisionHitTestDistance;
         if(this._fillMaterial)
         {
            this._currentFill.material = this._fillMaterial;
         }
         else if(this._fillTexture)
         {
            this._currentFill.material.texture = this._fillTexture;
         }
         if(this._fillMatrix)
         {
            this._currentFill.uvMatrix = this._fillMatrix;
         }
         this._currentFill.material.color = this._fillColor;
         this._currentFill.material.alpha = this._fillAlpha;
         if(this._fillDrawInBack)
         {
            this._container.addChildAt(this._currentFill,0);
         }
         else
         {
            this._container.addChild(this._currentFill);
         }
         if(this._penPosX == this._penPosX && this._penPosY == this._penPosY)
         {
            this._currentFill.addVertex(this._penPosX,this._penPosY);
         }
      }
   }
}
