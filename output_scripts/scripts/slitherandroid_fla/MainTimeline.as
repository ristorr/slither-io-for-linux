package slitherandroid_fla
{
   import adobe.utils.*;
   import flash.accessibility.*;
   import flash.desktop.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.external.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.globalization.*;
   import flash.media.*;
   import flash.net.*;
   import flash.net.drm.*;
   import flash.printing.*;
   import flash.profiler.*;
   import flash.sampler.*;
   import flash.sensors.*;
   import flash.system.*;
   import flash.text.*;
   import flash.text.engine.*;
   import flash.text.ime.*;
   import flash.ui.*;
   import flash.utils.*;
   import flash.xml.*;
   import gaim.*;
   import hypah.audio.*;
   import hypah.deadpool.*;
   import hypah.key.*;
   import hypah.lcr.*;
   import hypah.mode4.*;
   import starling.core.Starling;
   
   public dynamic class MainTimeline extends MovieClip
   {
       
      
      public var final_build;
      
      public var is_android;
      
      public var is_kindle;
      
      public var has_ads;
      
      public var ads_initialized;
      
      public var so:SharedObject;
      
      public var debug_strs;
      
      public var main:Main;
      
      public var root_mc;
      
      public var has_rate_box;
      
      public var did_rate_prompt;
      
      public var ettlaia;
      
      public var ltliatm;
      
      public var ciiiraatm;
      
      public var interstitial_loaded:Boolean;
      
      public var ad_trial_pos:Number;
      
      public var ads_to_try;
      
      public var ai;
      
      public var has_viral;
      
      public var has_generic_share;
      
      public var iaps_enabled;
      
      public function MainTimeline()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      public function tryLoadInterstitial() : *
      {
         if(this.has_ads && this.ads_initialized)
         {
            this.ettlaia = true;
            this.ciiiraatm = getTimer() + 3000;
            this.ltliatm = getTimer();
            this.interstitial_loaded = false;
            try
            {
            }
            catch(qe:*)
            {
            }
         }
      }
      
      public function adsInitializedHandler(param1:*) : *
      {
         this.ads_initialized = true;
      }
      
      public function handlePurchasedItem(param1:*) : *
      {
         if(param1 == "remove_ads")
         {
            this.main.setSo("disable_ads","1");
            this.disableAdsNow();
         }
      }
      
      public function showAd() : *
      {
         if(this.has_ads)
         {
            if(this.main.allow_ads)
            {
               this.main.afrqp += this.main.afrq;
               if(this.main.afrqp >= 1)
               {
                  --this.main.afrqp;
                  if(this.interstitial_loaded)
                  {
                     try
                     {
                     }
                     catch(qe:*)
                     {
                     }
                  }
               }
            }
         }
      }
      
      public function disableAdsNow() : *
      {
         this.has_ads = false;
         this.main.disableAdsNow();
      }
      
      public function loadInitialData() : *
      {
         this.main.loadInitialData();
      }
      
      internal function frame1() : *
      {
         this.final_build = true;
         this.is_android = true;
         this.is_kindle = false;
         this.has_ads = false;
         this.ads_initialized = false;
         this.debug_strs = [];
         this.main = new Main(stage,this,this.has_ads,this.is_android,this.is_kindle,this.final_build,0,this.debug_strs);
         this.root_mc = this;
         this.main.ready = function():*
         {
            if("" + main.getSo("disable_ads") == "1")
            {
               disableAdsNow();
            }
         };
         if(this.final_build)
         {
         }
         this.has_rate_box = false;
         this.did_rate_prompt = false;
         try
         {
            this.so = SharedObject.getLocal("game");
            if(this.so)
            {
               if(this.so.data)
               {
                  if(this.so.data.did_rate_prompt == "1")
                  {
                     this.did_rate_prompt = true;
                  }
               }
            }
         }
         catch(ee:*)
         {
         }
         this.ettlaia = false;
         this.ltliatm = 0;
         this.ciiiraatm = -1;
         this.interstitial_loaded = false;
         this.ad_trial_pos = 0;
         this.ads_to_try = [];
         if(this.final_build)
         {
            this.ai = 1;
            while(this.ai <= 5)
            {
               this.ads_to_try.push("ca-app-pub-0051214680937399/5587074315");
               ++this.ai;
            }
         }
         else
         {
            this.ads_to_try.push("ca-app-pub-3940256099942544/4411468910");
         }
         this.main.external_oef = function():*
         {
            var _loc1_:* = undefined;
            if(ettlaia)
            {
               if(ad_trial_pos < ads_to_try.length)
               {
                  if(ciiiraatm != -1)
                  {
                     _loc1_ = getTimer();
                     if(_loc1_ > ciiiraatm)
                     {
                        ciiiraatm = _loc1_ + 6000;
                        if(interstitial_loaded)
                        {
                           ciiiraatm = -1;
                        }
                        else if(_loc1_ - ltliatm > 15000)
                        {
                           tryLoadInterstitial();
                        }
                     }
                  }
               }
            }
         };
         if(!this.has_ads)
         {
         }
         this.has_viral = false;
         this.has_generic_share = false;
         this.main.purchase = function(param1:*):*
         {
            if(param1 == "RemoveAds")
            {
            }
         };
         this.iaps_enabled = false;
         this.main.showAd = function():*
         {
            var _loc1_:* = false;
            if(main.final_score > 100)
            {
               if(has_ads)
               {
                  if(has_rate_box && !did_rate_prompt)
                  {
                     did_rate_prompt = true;
                     try
                     {
                        so = SharedObject.getLocal("game");
                        if(so)
                        {
                           if(!so.data)
                           {
                           }
                        }
                     }
                     catch(ee:*)
                     {
                     }
                  }
               }
               if(!_loc1_)
               {
                  showAd();
               }
            }
         };
         this.main.loadFirstInterstitial = function():*
         {
            if(has_ads)
            {
               if(ads_initialized)
               {
                  tryLoadInterstitial();
               }
            }
         };
         this.main.share = function(param1:*, param2:*):*
         {
            if(has_viral)
            {
               if(!has_generic_share)
               {
               }
            }
         };
         this.main.gamtd = function(param1:*):*
         {
            var _loc2_:* = undefined;
            if(param1.length > 0)
            {
               ads_to_try = [];
               _loc2_ = 0;
               while(_loc2_ < param1.length)
               {
                  ads_to_try.push(param1[_loc2_]);
                  _loc2_++;
               }
            }
         };
         if(!this.final_build)
         {
            Starling.current.showStatsAt("left","top",1.25 * (!!this.main.is_mac ? 1 : 2));
         }
         setTimeout(this.loadInitialData,666);
      }
   }
}
