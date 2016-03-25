# ==============================================================================
# For 737-800 by Michael Soitanen
# ==============================================================================

var roundToNearest = func(n, m) {
	var x = int(n/m)*m;
	if((math.mod(n,m)) > (m/2) and n > 0)
			x = x + m;
	if((m - (math.mod(n,m))) > (m/2) and n < 0)
			x = x - m;
	return x;
}

var upperEICAS_canvas = nil;
var upperEICAS_display = nil;

var canvas_upperEICAS = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_upperEICAS] };
		var upperEICAS = canvas_group;
		var font_mapper = func(family, weight)
		{
			if( family == "Liberation Sans" and weight == "normal" )
				return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(upperEICAS, "Aircraft/737-800/Models/Instruments/EICAS/upperEICAS.svg", {'font-mapper': font_mapper});
		
		var svg_keys = ["engine0N1","engine0N1Decimal","engine1N1","engine1N1Decimal",
		"EGT_0","EGT_1","needleEGT_0","needleEGT_1","ff_0","ff_1",
		"needleN1_0","needleN1_1","tat",
		"tank1Thousand","tank1Decimal","tank2Thousand","tank2Decimal","tankCtrThousand","tankCtrDecimal",
		"tank1Line"];
		foreach(var key; svg_keys) {
			m[key] = upperEICAS.getElementById(key);
		}

		return m;
	},
	update: func()
	{
		var n1_0 = getprop("/engines/engine[0]/n1");
		var n1_1 = getprop("/engines/engine[1]/n1");
		var egt_0 = (getprop("/engines/engine[0]/egt-degf")-32)/1.8;
		var egt_1 = (getprop("/engines/engine[1]/egt-degf")-32)/1.8;
		var fuel_flow_0 = getprop("/engines/engine[0]/fuel-flow_pph")*0.4536/1000;
		var fuel_flow_1 = getprop("/engines/engine[1]/fuel-flow_pph")*0.4536/1000;
		var tat = roundToNearest(getprop("/fdm/jsbsim/propulsion/tat-c"),1);
		var tank1 = roundToNearest(getprop("/consumables/fuel/tank[0]/level-kg"), 20);
		var tank2 = roundToNearest(getprop("/consumables/fuel/tank[1]/level-kg"), 20);
		var tankCtr = roundToNearest(getprop("/consumables/fuel/tank[2]/level-kg"), 20);

		var n1_0_int = int(n1_0);
		var n1_0_dec = int(10*math.mod(n1_0,1));
		var n1_1_int = int(n1_1);
		var n1_1_dec = int(10*math.mod(n1_1,1));

		me["engine0N1"].setText(sprintf("%s", n1_0_int));
		me["engine0N1Decimal"].setText(sprintf("%s", n1_0_dec));
		me["engine1N1"].setText(sprintf("%s", n1_1_int));
		me["engine1N1Decimal"].setText(sprintf("%s", n1_1_dec));
		me["needleN1_0"].setRotation(n1_0*1.965*D2R);
		me["needleN1_1"].setRotation(n1_1*1.965*D2R);

		me["EGT_0"].setText(sprintf("%3.0f",egt_0));
		me["EGT_1"].setText(sprintf("%3.0f",egt_1));
		me["needleEGT_0"].setRotation(egt_0*0.2015*D2R);
		me["needleEGT_1"].setRotation(egt_1*0.2015*D2R);

		me["ff_0"].setText(sprintf("%01.2f",fuel_flow_0));
		me["ff_1"].setText(sprintf("%01.2f",fuel_flow_1));

		me["tat"].setText(sprintf("%+2.0f", tat));

		if (tank1 < 1000 ) {
			me["tank1Thousand"].hide();
			me["tank1Decimal"].setText(sprintf("%3.0f",math.mod(tank1,1000)));
		} else {
			me["tank1Thousand"].show();
			me["tank1Thousand"].setText(sprintf("%1.0f",int(tank1/1000)));
			me["tank1Decimal"].setText(sprintf("%03.0f",math.mod(tank1,1000)));
		}
		if (tank2 < 1000 ) {
			me["tank2Thousand"].hide();
			me["tank2Decimal"].setText(sprintf("%3.0f",math.mod(tank2,1000)));
		} else {
			me["tank2Thousand"].show();
			me["tank2Thousand"].setText(sprintf("%1.0f",int(tank2/1000)));
			me["tank2Decimal"].setText(sprintf("%03.0f",math.mod(tank2,1000)));
		}
		if (tankCtr < 1000 ) {
			me["tankCtrThousand"].hide();
			me["tankCtrDecimal"].setText(sprintf("%3.0f",math.mod(tankCtr,1000)));
		} else {
			me["tankCtrThousand"].show();
			me["tankCtrThousand"].setText(sprintf("%1.0f",int(tankCtr/1000)));
			me["tankCtrDecimal"].setText(sprintf("%03.0f",math.mod(tankCtr,1000)));
		}

		me["tank1Line"].setData([2, 25],[0, 1024, 512, 512, 0, 0, -1024]);
		


		settimer(func me.update(), 0.04);
	},
};

setlistener("sim/signals/fdm-initialized", func() {
	upperEICAS_display = canvas.new({
		"name": "upperEICAS",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	upperEICAS_display.addPlacement({"node": "upperEICASScreen"});
	var group = upperEICAS_display.createGroup();
	upperEICAS_canvas = canvas_upperEICAS.new(group);
	upperEICAS_canvas.update();
});

#setlistener("sim/signals/reinit", func upperEICAS_display.del());

var showupperEICAS = func() {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(upperEICAS_display);
}
