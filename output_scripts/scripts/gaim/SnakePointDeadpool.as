package gaim
{
   public class SnakePointDeadpool
   {
       
      
      public var os:Vector.<gaim.SnakePoint>;
      
      public var len:int = 0;
      
      public var end_pos:int = 0;
      
      public function SnakePointDeadpool()
      {
         this.os = new Vector.<gaim.SnakePoint>();
         super();
      }
      
      public function add(param1:gaim.SnakePoint) : *
      {
         if(this.end_pos == this.len)
         {
            this.os.push(param1);
            ++this.len;
         }
         else
         {
            this.os[this.end_pos] = param1;
         }
         ++this.end_pos;
      }
      
      public function get() : gaim.SnakePoint
      {
         var _loc1_:gaim.SnakePoint = null;
         if(this.end_pos >= 1)
         {
            --this.end_pos;
            _loc1_ = this.os[this.end_pos];
            this.os[this.end_pos] = null;
            return _loc1_;
         }
         return null;
      }
   }
}
