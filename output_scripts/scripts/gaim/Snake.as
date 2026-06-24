package gaim
{
   import starling.display.Image;
   
   public class Snake
   {
       
      
      public var id:int;
      
      public var xx:Number;
      
      public var yy:Number;
      
      public var segs:Vector.<gaim.Segment>;
      
      public var sgc:int = 0;
      
      public var lmsgp:int = -1;
      
      public var cv:int;
      
      public var rcv:int;
      
      public var arrow_color:int;
      
      public var er:Number;
      
      public var ec:int;
      
      public var eca:Number;
      
      public var ppa:Number;
      
      public var ppc:int;
      
      public var antenna:Boolean;
      
      public var antenna_shown:Boolean = false;
      
      public var accessory:Number;
      
      public var one_eye:Boolean;
      
      public var ebi:Image;
      
      public var ebiw:int;
      
      public var ebih:int;
      
      public var ebisz:Number;
      
      public var epi:Image;
      
      public var epiw:int;
      
      public var epih:int;
      
      public var episz:Number;
      
      public var pr:Number;
      
      public var eo:Number;
      
      public var easp:Number;
      
      public var pma:Number;
      
      public var swell:Number;
      
      public var atba:Number;
      
      public var atc1:Number;
      
      public var atc2:Number;
      
      public var atia:Number;
      
      public var apbs:Boolean;
      
      public var abrot:Boolean;
      
      public var atpc:int = 0;
      
      public var atx:Vector.<Number>;
      
      public var aty:Vector.<Number>;
      
      public var atvx:Vector.<Number>;
      
      public var atvy:Vector.<Number>;
      
      public var atax:Vector.<Number>;
      
      public var atay:Vector.<Number>;
      
      public var ssds:Vector.<gaim.SkinSegmentData> = null;
      
      public var static_ssds:Boolean = false;
      
      public var rbl:int;
      
      public var skin_type:int;
      
      public var cusk:Boolean;
      
      public var bulb:Image;
      
      public var bsc:Number;
      
      public var blba:Number;
      
      public var blbx:Number;
      
      public var blby:Number;
      
      public var blbw:Number;
      
      public var blbh:Number;
      
      public var atwg:Boolean;
      
      public var fnfr:int;
      
      public var na:Number;
      
      public var chl:Number;
      
      public var rr:int;
      
      public var gg:int;
      
      public var bb:int;
      
      public var cs:int;
      
      public var ac:int;
      
      public var csw:int;
      
      public var cpid:int;
      
      public var edir:int;
      
      public var dir:int;
      
      public var sep:Number;
      
      public var wsep:Number;
      
      public var bsep:Number;
      
      public var tsp:Number;
      
      public var sfr:Number;
      
      public var ssp:Number;
      
      public var fsp:Number;
      
      public var msp:Number;
      
      public var fxs:Vector.<Number>;
      
      public var fys:Vector.<Number>;
      
      public var fchls:Vector.<Number>;
      
      public var fpos:int;
      
      public var ftg:int;
      
      public var fx:Number;
      
      public var fy:Number;
      
      public var fchl:Number;
      
      public var fas:Vector.<Number>;
      
      public var fapos:int;
      
      public var fatg:int;
      
      public var fa:Number;
      
      public var ehang:Number;
      
      public var wehang:Number;
      
      public var ehl:Number;
      
      public var ed:Number;
      
      public var esp:Number;
      
      public var eac:Boolean;
      
      public var jyt:Boolean;
      
      public var slg:Boolean;
      
      public var drez:Boolean;
      
      public var fdhc:int;
      
      public var fdtc:int;
      
      public var fdl:int;
      
      public var fam:Number;
      
      public var ang:Number;
      
      public var eang:Number;
      
      public var wang:Number;
      
      public var rex:Number;
      
      public var rey:Number;
      
      public var sp:Number;
      
      public var lnp:gaim.SnakePoint;
      
      public var pts:Vector.<gaim.SnakePoint>;
      
      public var sct:int;
      
      public var rsc:int;
      
      public var msl:Number;
      
      public var has_shadow:Boolean;
      
      public var head_180:Boolean;
      
      public var animated:Boolean;
      
      public var anim_frames:int;
      
      public var anim_fr:Number;
      
      public var anim_steps:int;
      
      public var anim_random:Boolean;
      
      public var anim_staggered:Boolean;
      
      public var flpos:int;
      
      public var fls:Vector.<Number>;
      
      public var fltg:int;
      
      public var fl:Number;
      
      public var csi:Number;
      
      public var csy:Number;
      
      public var cssc:Number;
      
      public var csfr:Number;
      
      public var nick:String;
      
      public var tl:Number;
      
      public var cfl:Number;
      
      public var hlt:Boolean = false;
      
      public var ltipx:Number;
      
      public var ltipy:Number;
      
      public var accelerating:Boolean = false;
      
      public var acceleration_amount:Number = 0;
      
      public var normal_speed:Number;
      
      public var last_poop_tm:Number = 0;
      
      public var sc:Number;
      
      public var sc13:Number;
      
      public var lsz:Number;
      
      public var scang:Number;
      
      public var spang:Number;
      
      public var dead_amt:Number;
      
      public var alive_amt:Number;
      
      public var dead:Boolean;
      
      public var iiv:Boolean;
      
      public var kill_count:int = 0;
      
      public var kill_count_changed:Boolean = true;
      
      public var cowardice:Number;
      
      public var violent:Boolean = false;
      
      public var stop_violence_after_tm:Number;
      
      public var excited:Boolean = false;
      
      public var stop_excitement_after_tm:Number;
      
      public var change_target_after_mtm:Number;
      
      public var last_avoidance_dir_change_mtm:Number;
      
      public var avoidance_dir:Number;
      
      public var target_food:gaim.Food = null;
      
      public var collided:Boolean = false;
      
      public function Snake()
      {
         this.segs = new Vector.<gaim.Segment>();
         this.atx = new Vector.<Number>(32);
         this.aty = new Vector.<Number>(32);
         this.atvx = new Vector.<Number>(32);
         this.atvy = new Vector.<Number>(32);
         this.atax = new Vector.<Number>(32);
         this.atay = new Vector.<Number>(32);
         super();
      }
   }
}
