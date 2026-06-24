package starling.display.graphics
{
   import starling.display.util.GPool;
   
   public final class VertexList
   {
      
      private static var temp:starling.display.graphics.VertexList;
      
      private static var newHead:starling.display.graphics.VertexList;
      
      private static var currentVertexNode:starling.display.graphics.VertexList;
      
      private static var currentClonedNode:starling.display.graphics.VertexList;
      
      private static var newClonedNode:starling.display.graphics.VertexList;
      
      private static var i:int;
      
      private static var len:int;
      
      private static var vertexListTemp:starling.display.graphics.VertexList;
      
      private static var vertexListNode:starling.display.graphics.VertexList;
      
      private static var nodePool:Vector.<starling.display.graphics.VertexList> = new Vector.<starling.display.graphics.VertexList>();
      
      private static var nodePoolLength:int = 0;
       
      
      public var vertex:Vector.<Number>;
      
      public var next:starling.display.graphics.VertexList;
      
      public var prev:starling.display.graphics.VertexList;
      
      public var index:int;
      
      public var head:starling.display.graphics.VertexList;
      
      public function VertexList()
      {
         super();
         this.vertex = GPool.getNumberVector();
      }
      
      public static function insertAfter(param1:starling.display.graphics.VertexList, param2:starling.display.graphics.VertexList) : starling.display.graphics.VertexList
      {
         temp = param1.next;
         param1.next = param2;
         param2.next = temp;
         param2.prev = param1;
         param2.head = param1.head;
         return param2;
      }
      
      public static function clone(param1:starling.display.graphics.VertexList) : starling.display.graphics.VertexList
      {
         newHead = null;
         currentVertexNode = param1.head;
         currentClonedNode = null;
         do
         {
            if(newHead == null)
            {
               newClonedNode = newHead = getNode();
            }
            else
            {
               newClonedNode = getNode();
            }
            newClonedNode.head = newHead;
            newClonedNode.index = currentVertexNode.index;
            i = 0;
            len = currentVertexNode.vertex.length;
            while(i < len)
            {
               newClonedNode.vertex[i] = currentVertexNode.vertex[i];
               ++i;
            }
            newClonedNode.prev = currentClonedNode;
            if(currentClonedNode)
            {
               currentClonedNode.next = newClonedNode;
            }
            currentClonedNode = newClonedNode;
            currentVertexNode = currentVertexNode.next;
         }
         while(currentVertexNode != currentVertexNode.head);
         
         currentClonedNode.next = newHead;
         newHead.prev = currentClonedNode;
         return newHead;
      }
      
      public static function reverse(param1:starling.display.graphics.VertexList) : void
      {
         vertexListNode = param1.head;
         do
         {
            vertexListTemp = vertexListNode.next;
            vertexListNode.next = vertexListNode.prev;
            vertexListNode.prev = vertexListTemp;
            vertexListNode = vertexListTemp;
         }
         while(vertexListNode != param1.head);
         
      }
      
      public static function dispose(param1:starling.display.graphics.VertexList) : void
      {
         while(Boolean(param1) && Boolean(param1.head))
         {
            if(param1.vertex)
            {
               param1.vertex.length = 0;
               GPool.putNumberVector(param1.vertex);
               param1.vertex = null;
            }
            releaseNode(param1);
            vertexListTemp = param1.next;
            param1.next = null;
            param1.prev = null;
            param1.head = null;
            param1 = vertexListTemp;
         }
      }
      
      public static function getNode() : starling.display.graphics.VertexList
      {
         if(nodePoolLength > 0)
         {
            --nodePoolLength;
            vertexListNode = nodePool.pop();
            if(!vertexListNode.vertex)
            {
               vertexListNode.vertex = GPool.getNumberVector();
            }
            return vertexListNode;
         }
         return new starling.display.graphics.VertexList();
      }
      
      public static function releaseNode(param1:starling.display.graphics.VertexList) : void
      {
         param1.prev = param1.next = param1.head = null;
         param1.vertex = null;
         param1.index = -1;
         var _loc2_:* = nodePoolLength++;
         nodePool[_loc2_] = param1;
      }
   }
}
