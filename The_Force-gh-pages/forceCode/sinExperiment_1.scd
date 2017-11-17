(

n = NetAddr("localhost", 7500);

t = TempoClock.new(2);

t.sched(0, {
    n.sendMsg("/msg2", t.beats.sin, t.beats.cos, 0, 0);
    [t.beats.sin, t.beats.cos].postln;
    0.1
});

)

