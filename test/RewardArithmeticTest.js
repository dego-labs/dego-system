let degoSegment = {};
let playerMap = {};

function updateDegoSegment(index, min, max) {
  let config = {};
  config.min = min;
  config.max = max;
  degoSegment[index] = config;
}

function updateRuler(maxCount, func) {
  //console.log("updateRuler", maxCount)
  let ruler = [0.8, 0.1, 0.1];
  let factor = [1, 3, 5];

  let lastBegin = 0;
  let lastEnd = 0;
  let splitPoint = 0;
  for (let i = 1; i <= ruler.length; i++) {
    splitPoint = Math.floor(maxCount * ruler[i - 1]);
    if (splitPoint <= 0) {
      splitPoint = 1;
    }
    //console.log("----->", i, "----", lastBegin + 1, "----", lastEnd,"----",splitPoint)
    lastEnd = lastBegin + splitPoint;
    if (i == ruler.length) {
      lastEnd = maxCount;
    }
    func(i, lastBegin + 1, lastEnd);
    //console.log("----->", i, "----", lastBegin + 1, "----", lastEnd, "-----dt", lastEnd - lastBegin)
    lastBegin = lastEnd;
  }
}

let high = 3;
let mid = 2;
let low = 1;

let countSegment = {}
countSegment[high] = {};
countSegment[high].length = 2;
countSegment[high].curCount = 0;
countSegment[high].playerIds = {};

countSegment[mid] = {};
countSegment[mid].length = 2;
countSegment[mid].curCount = 0;
countSegment[mid].playerIds = {};

countSegment[low] = {};
countSegment[low].length = 96;
countSegment[low].curCount = 0;
countSegment[low].playerIds = {};

function checkCountSegmentSlot(segIndex) {
  let value = countSegment[segIndex].length - countSegment[segIndex].curCount;
  if (value > 0) {
    return true;
  } else {
    return false;
  }
}



function findSegmentMinPlayer(segIndex) {
  let firstMinAmount = degoSegment[segIndex].max;
  let secondMinAmount = degoSegment[segIndex].max;
  let minPlayerOffset = 0;
  for (let i = 0; i < countSegment[segIndex].curCount; i++) {
    let playerId = countSegment[segIndex].playerIds[i];
    if (playerId == 0) {
      continue;
    }
    let amount = playerMap[playerId].amount;

    //console.log(">>>>>>>>>>>>1",amount," 1:",firstMinAmount," 2:",secondMinAmount)

    //find min amount;
    if (amount < firstMinAmount) {
      if (firstMinAmount < secondMinAmount) {
          secondMinAmount = firstMinAmount;
      }
      firstMinAmount = amount;
      minPlayerOffset = i;
    } else {
      //find second min amount
      if (amount < secondMinAmount) {
        secondMinAmount = amount;
      }
    }
  }


  return {
    index: minPlayerOffset,
    amount: secondMinAmount

  }
}



  let G_playerId = 0;
  let nameXId = {};

  function determinPlayer(name) {
    let playerId = nameXId[name];
    if (playerMap[playerId]) {
      return playerId;
    } else {
      G_playerId++;
      nameXId[name] = G_playerId;
      return G_playerId;
    }
  }


  //swap the player data from old segment to the new segment
  function JoinSwap(playerId, segIndex) {

    //console.log("------->JoinSwap begin:",segIndex,playerId,countSegment[segIndex].playerIds)

    let tail = countSegment[segIndex].curCount;

    playerMap[playerId].segIndex = segIndex;
    playerMap[playerId].offSet = tail;

    countSegment[segIndex].curCount = countSegment[segIndex].curCount + 1;
    countSegment[segIndex].playerIds[tail] = playerId;

    //console.log("------->JoinSwap begin:",segIndex,playerId,countSegment[segIndex].playerIds)

  }

  //get the leftPlayerId from a segment
  function LeaveSwap(playerId) {

    let originSeg = playerMap[playerId].segIndex;
    let originOffset = playerMap[playerId].offSet;

    if(originSeg ==0 ){
      return;
    }

    //console.log("------->LeaveSwap begin:",originSeg,playerId,countSegment[originSeg].playerIds)

    let tail = countSegment[originSeg].curCount - 1;
    let tailPlayerId = countSegment[originSeg].playerIds[tail];
    playerMap[tailPlayerId].offSet = originOffset;
    countSegment[originSeg].playerIds[originOffset] = tailPlayerId;

    countSegment[originSeg].playerIds[tail] = 0;
    countSegment[originSeg].curCount--;

    //console.log("------->LeaveSwap end:",originSeg,playerId,countSegment[originSeg].playerIds)

  }


  //get the leftPlayerId from a segment
  function doLeave(playerId,segIndex) {

    let result = findSegmentMinPlayer(segIndex);
    let minPlayerOffSet = result.index;
    let secondMinAmount = result.amount;

    let playerAmount = playerMap[playerId].amount;
    degoSegment[segIndex].min = secondMinAmount<playerAmount?secondMinAmount:playerAmount;

    let leftPlayerId = countSegment[segIndex].playerIds[minPlayerOffSet];
    return leftPlayerId;

  }

  function joinHigh(playerId) {

    console.log(playerId,"joinHigh")
  
    LeaveSwap(playerId);

    let segIndex = high;
    if (checkCountSegmentSlot(segIndex)) {
      JoinSwap(playerId, segIndex);
    } else {

      let leftPlayerId = doLeave(playerId,segIndex);
      joinMid(leftPlayerId);
      
      JoinSwap(playerId, segIndex)
    }
  }

  function joinMid(playerId) {

    console.log(playerId,"joinMid")

    LeaveSwap(playerId);

    let segIndex = mid;
    if (checkCountSegmentSlot(segIndex)) {
      JoinSwap(playerId, segIndex);
    } else {
      let leftPlayerId = doLeave(playerId,segIndex)
      joinLow(leftPlayerId);
      JoinSwap(playerId, segIndex)

    }
    degoSegment[segIndex].max = degoSegment[segIndex+1].min;
  }

  function joinLow(playerId) {

    console.log(playerId,"joinLow")

    LeaveSwap(playerId);

    let segIndex = low;
    JoinSwap(playerId, segIndex);
    
    degoSegment[segIndex].max = degoSegment[segIndex+1].min;
    //low segment length update
    if (countSegment[segIndex].curCount > countSegment[segIndex].length) {
      countSegment[segIndex].length = countSegment[segIndex].curCount;
    }

  }

  function updateCountSegment() {
    let base = 100;
    let anchor = base;
    let grouthStep = 10;
    let highMax = 50;
    let midMax = 50;

    if (G_playerId - anchor >= grouthStep) {
      if (countSegment[high].length + grouthStep > highMax) {
        countSegment[high].length = highMax;
      } else {
        countSegment[high].length += grouthStep
      }

      if (countSegment[mid].length + grouthStep > midMax) {
        countSegment[mid].length = midMax;
      } else {
        countSegment[mid].length += grouthStep
      }
      anchor = G_playerId;
    }
  }

  function join(name, amount) {

    updateCountSegment();

    let segIndex = 0;
    for (let i = 1; i <= high; i++) {
      if (amount < degoSegment[i].max) {
        segIndex = i;
        break;
      }
    }

    if (segIndex == 0) {
      degoSegment[high].max = amount;
      segIndex = high;
    }

    let playerId = determinPlayer(name, amount);
    playerMap[playerId] = {
      name: name,
      playerId: playerId,
      amount: amount,
      segIndex: 0,
      offSet: 0
    }
    if (segIndex == high) {
      joinHigh(playerId);
    } else if (segIndex == mid) {
      joinMid(playerId);
    } else {
      joinLow(playerId);
    }
  }

  function change(playerId, amount) {

    console.log("change playerId,amount",playerId,amount)

    let segIndex = 0;
    for (let i = 1; i <= high; i++) {
      if (amount < degoSegment[i].max) {
        segIndex = i;
        break;
      }
    }
    if (segIndex == 0) {
      degoSegment[high].max = amount;
      segIndex = high;
    }

    if (playerMap[playerId]) {

      playerMap[playerId].amount = amount;
      if (playerMap[playerId].segIndex == segIndex) {
        return;
      }

      if (segIndex == high) {
        joinHigh(playerId);
      } else if (segIndex == mid) {
        joinMid(playerId);
      } else {
        joinLow(playerId);
      }

    }
  }

  {

  updateRuler(10000, updateDegoSegment);

  ///////////////////////
  let base = 400;
  let max = 550;
  for (let i = 0; i < max; i++) {
    join("name_" + i, i * 100);
  }

  console.log(degoSegment)
  console.log(countSegment)


  // join("name_" + 1, 800);
  // join("name_" + 2, 900);
  // join("name_" + 12, 900);
  // change(1, 8500)

  for (let i = base; i < max; i++) {
    change(i, 8500)
  }

  console.log(countSegment)


  for (let i = base; i < max; i++) {
    change(i, 9500)
  }
  console.log(countSegment)


  for (let i = base; i < max; i++) {
    change(i, 9600)
  }
  console.log(countSegment)


  for (let i = base; i < max; i++) {
    change(i, 198000)
  }
  console.log(countSegment)
  //console.log(playerMap)


  console.log(degoSegment)


  // join("name_" + 1, 850);
  // join("name_" + 2, 850);
  // join("name_" + 3, 850);

  // join("name_" + 4, 899);
  // join("name_" + 5, 999);
  // join("name_" + 6, 999);

  // join("name_" + 7, 999);
  // join("name_" + 8, 1000);
  // change(1, 1000);

  // console.log(countSegment)
  // console.log(degoSegment)
}




// updateRuler(100, updateDegoSegment);


// join("shit1", 1000);
// join("shit2", 45);
// join("shit3", 88);
// join("shit4", 85);
// join("shit5", 87);
// join("shit6", 95);

// //console.log(countSegment)

// // // console.log("---------------------------")

// join("shit7", 98);
// // // // join("shit6", 98);


// // // //console.log(playerMap);
// // // console.log(degoSegment)
// // // console.log(countSegment)
// // // console.log("---------------------------")

// change(2, 99);

// console.log(playerMap);
// console.log(degoSegment)
// console.log(countSegment)
