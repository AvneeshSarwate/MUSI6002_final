(
var midiOutVox, chords, markov, normalize, markovStep, tempoClock, state, playChord, chordStep, markovNorm, altChords, chordTask, bassLineTask, counterTask, lineFunction, maxPort, pythonPort, lineInd, onsetBuffer, generateAndStartBassLine, activeChord, playNote, midiOutBass, createAndPlayChordProgression, valence, splitNote;

MIDIClient.init;
MIDIIn.connectAll;

midiOutVox = MIDIOut.newByName("IAC Driver", "Bus 2");
midiOutBass = MIDIOut.newByName("IAC Driver", "Bus 3");
maxPort = NetAddr("127.0.0.1", 1234);
pythonPort = NetAddr("127.0.0.1", 6003);


tempoClock = TempoClock.new(4/4, 0); //denominator is number of secods for 4 bars
~clock = tempoClock;

chords = List.new;
chords.add([60, 64, 67, 72]);
chords.add([57, 62, 65, 69]);
chords.add([55, 59, 62, 65]);
chords.add([53, 57, 60, 65]);
chords.add([54, 57, 60, 62]);

[chords.size, "CHORD LENGTH"].postln;

activeChord = chords[0];


altChords = List.new;
altChords.add((60,63..69));
altChords.add((57,60..66));
altChords.add((55,58..64));
altChords.add((53,56..62));
altChords.add((54,57..63));

c = chords;

state = 0;


markov = [
    [9, 8, 7, 6, 5],
    [4, 3, 2, 1, 2],
    [9, 8, 7, 6, 5],
    [4, 3, 2, 1, 2],
    [9, 8, 7, 6, 5],
];

normalize = {|markovMat|
    var normMat = markovMat.deepCopy;
    normMat.size.do({|ind|
        normMat[ind] = normMat[ind] / normMat[ind].sum
    });
    normMat
};

markovStep = {|transitions, state|
    var stateTrans = transitions.[state];
    var rand = 1.0.rand;
    var accum = stateTrans[0];
    var newState = block {|break| stateTrans.size.do({|ind|
        if(rand < accum,
            {break.value(ind)},
            {accum = accum+stateTrans[ind+1]}
        )
    })};
    newState
};

markovNorm = normalize.(markov);

playChord = {|chord, waitTime|
    //["CHORD PLAY", chord].postln;
    chord.do({|note|
        Task({
            midiOutVox.noteOn(1, note);
            (waitTime-0.05).wait;
            midiOutVox.noteOff(1, note);
        }, tempoClock).play;
    });
    waitTime
};


valence = 1;
OSCFunc({|msg, time, addr, recvPort|
    valence = if(msg[1] != 0, msg[1], valence);
}, "/valence");

createAndPlayChordProgression = {
    var chordDurations = List.new;
    while({chordDurations.sum < 4}, {
        chordDurations.add([0.25, 0.5, 0.75].choose);
    });
    if(chordDurations.sum > 4, {
        chordDurations.pop;
        chordDurations.add(4 - chordDurations.sum);
    });

    chordDurations = [4];

    Task({
        chordDurations.do({|dur|
            var chordCopy;
            state = markovStep.(markovNorm, state);
            activeChord = if(valence > 0, chords[state], altChords[state]);
            chordCopy = activeChord.deepCopy;
            //["MARKOV STATE", state, chordCopy, chords.size].postln;
            playChord.(chordCopy, dur).wait;
        })
    }, tempoClock).play;

};







onsetBuffer = List.new;
OSCFunc({|msg, time, addr, recvPort|
    //["onset", tempoClock.beats].postln;
    onsetBuffer.add(tempoClock.beats);
}, "/onset");

playNote = {|note, dur|
    Task({
        midiOutBass.noteOn(1, note);
        dur.wait - 0.05;
        midiOutBass.noteOff(1, note);
    }).play;
    dur;
};

splitNote = 0;
OSCFunc({|msg, time, addr, recvPort|
    msg.postln;
    splitNote = msg[1];
}, "/splitNote");

generateAndStartBassLine = {
    var startBeat = onsetBuffer[0].floor;
    var hitBuffer = onsetBuffer - startBeat;
    var endBeat = hitBuffer.wrapAt(-1).ceil;
    var duplicateRemovedHits;
    var durations;

    (0..(hitBuffer.size-1)).do({|i|
        var hit = hitBuffer[i];
        var timeToNextHit = ~quantizeValue - (hit % ~quantizeValue);
        var nextHit = hit + timeToNextHit;
        var lastHit = nextHit - ~quantizeValue;
        hitBuffer[i] = if((lastHit-hit).abs < (nextHit-hit).abs, lastHit, nextHit);
    });

    duplicateRemovedHits = List.newFrom(Set.newFrom(hitBuffer)).sort;
    duplicateRemovedHits.add(endBeat);
    durations = List.new;
    (0..(duplicateRemovedHits.size-2)).do({|i|
        durations.add(duplicateRemovedHits[i+1] - duplicateRemovedHits[i]);
    });

    //"Playing bassline".postln;

    Task({
        durations.do({|dur|
            var numSplits = dur / ~quantizeValue;
            if((numSplits > 1) && (1.0.rand < splitNote),
                {
                    var note = activeChord.choose - 24;
                    var dur1 = (numSplits/2).floor;
                    var dur2 = (numSplits/2).ceil;
                    playNote.(note, dur1).wait;
                    note = activeChord.choose - 24;
                    playNote.(note, dur2).wait;
                },
                {
                    var note = activeChord.choose - 24;
                    playNote.(note, dur).wait;
                }
            );
        })
    }, tempoClock).play;

    onsetBuffer.clear;
};




lineInd = 0;
~quantizeValue = 1/4;

counterTask = Task({
    var ind = 0;
    var quantizeVal = 1/4;

    {
        if(ind == 0, {
            Task({
                pythonPort.sendMsg("/getLine", lineInd);
                0.01.wait;
                createAndPlayChordProgression.();
                0.01.wait;
                if(onsetBuffer.size > 0, {generateAndStartBassLine.()});
            }).play;
            lineInd = lineInd + 1;
        });
        (1/25).wait;
        maxPort.sendMsg("/counterStep", ind);
        ind = (ind + 1) % 100;


    }.loop

}, tempoClock);
counterTask.play;

)


//================================================================================================
//================================================================================================






(


a = List.newFrom(Set.newFrom([1, 2, 3, 3])).sort;


a.pop;

a.postln;

)

(

var markov = [
    [1, 1, 0, 0, 0],
    [0, 1, 1, 0, 0],
    [0, 0, 1, 1, 0],
    [0, 0, 0, 1, 1],
    [1, 0, 0, 0, 1],
];

var normalize = {|markovMat|
    var normMat = markovMat.deepCopy;
    normMat.size.do({|ind|
        normMat[ind] = normMat[ind] / normMat[ind].sum
    });
    normMat
};

var norm = normalize.(markov);

var state = 0;

var markovStep = {|transitions, state|
    var stateTrans = transitions.[state];
    var rand = 1.0.rand;
    var accum = stateTrans[0];
    var newState = block {|break| stateTrans.size.do({|ind|
        if(rand < accum,
            {break.value(ind)},
            {accum = accum+stateTrans[ind+1]}
        )
    })};
    newState
};
(0..10).do({
    state = markovStep.(norm, state);
    state.postln;
})
)
