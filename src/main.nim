import random, sequtils

import nico


type
  Obst = tuple
    x, y: int


const
  gameWidth = 8
  gameHeight = 12
  spriteSize = 16
  carWidth = spriteSize
  carHeight = spriteSize
  obstWidth = carWidth
  obstHeight = spriteSize
  obstTimeout = 0.2
  obstFreq = 0.2

var
  carX = (gameWidth div 2) * carWidth
  carY = (gameHeight - 3) * carHeight
  score: Natural
  obsts: seq[Obst]
  obstPause: float
  obstSize: Positive
  gameOver: bool


proc gameInit() =
  loadFont(0, "font.png")
  loadSpritesheet(0, "spritesheet.png", spriteSize, spriteSize)

proc gameUpdate(dt: float32) =
  if gameOver:
    if btnp(pcStart):
      obsts.setLen(0)
      score = 0
      gameOver = false

    return

  if btnpr(pcLeft, repeat = 5):
    if carX > 0:
      carX -= carWidth
  if btnpr(pcRight, repeat = 5):
    if carX < screenWidth - carWidth:
      carX += carWidth
  if btnpr(pcUp, repeat = 5):
    if carY > screenHeight div 2:
      carY -= carHeight
  if btnpr(pcDown, repeat = 5):
    if carY < screenHeight - carHeight:
      carY += carHeight


  if obstPause > 0.0:
    obstPause -= dt
  else:
    for obst in obsts.mitems:
      obst.y += obstHeight

      if obst.x == carX and obst.y >= carY and obst.y <= (carY + carHeight):
        gameOver = true

    obstSize = if score > 80: obstSize else: (score div 10) + 1

    score += len(obsts.filterIt(it.y > screenHeight)) div obstSize

    obsts.keepItIf(it.y <= screenHeight)

    if rand(1.0) < obstFreq:
      var slots = (0..<gameWidth).toSeq
      shuffle slots

      let obstSlots = slots[0..<obstSize]

      for i in 0..<gameWidth:
        if i in obstSlots:
          obsts.add (x: i * obstWidth, y: 0)

    obstPause = obstTimeout

proc gameDraw() =
  cls()
  setColor(7)
  boxFill(0, 0, screenWidth, screenHeight)

  if gameOver:
    setColor(0)
    printc("Game Over, score: " & $score, screenWidth div 2, screenHeight div 2)

    return

  setColor(3)
  spr(0, carX, carY)

  setColor(2)
  for obst in obsts:
    spr(1, obst.x, obst.y)

  setColor(0)
  print($score, 0, 0)


when isMainModule:
  randomize()

  nico.init("moigagoo", "Love Race")
  nico.createWindow("Love Race", gameWidth * carWidth, gameHeight * carHeight, scale = 4, fullscreen = false)
  nico.run(gameInit, gameUpdate, gameDraw)
