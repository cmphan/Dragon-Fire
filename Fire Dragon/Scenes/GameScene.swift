//
//  GameScene.swift
// 
//
//  Created by Cuong Phan on 11/17/18.
//  Copyright © 2018 Cuong Phan. All rights reserved.
//

import SpriteKit
import GameplayKit
class GameScene: SKScene, SKPhysicsContactDelegate {
    /*================================================================
     
    Declare all variables sound, dragon, fireball, boom explosion, enemy, game over....
     
     =======================================================================*/
    let sound = SKAction.playSoundFileNamed("sfx_swooshing.wav", waitForCompletion: false)
    let soundHit = SKAction.playSoundFileNamed("sfx_hit.wav", waitForCompletion: false)
    let soundExplosion = SKAction.playSoundFileNamed("explosin.wav", waitForCompletion: false)
    var dragon  = SKSpriteNode()
    var bg = SKSpriteNode()
    var fireball = SKSpriteNode()
    var boomExplosion = SKSpriteNode()
    var Enemy = SKSpriteNode()
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var highestScoreLabel = SKLabelNode()
    var TapTap = SKLabelNode()
    var score = 0
    var timer1 = Timer()
    var timer2 = Timer()
    var highestScore: Int = 0
    var gameOver = false
    /*================================================================
     
     End of Declare all variables sound, dragon, fireball, boom explosion, enemy, game over....
     
     =======================================================================*/
    
    /*================================================================
     
     Enum to handle collision. Bird vs Object = 1 + 2 =3 for example
     
     =======================================================================*/
    enum ColliderType: UInt32
    {
        case Bird = 1
        case Object = 2
        case Gap = 4
        case Enemy = 8
        case Fire = 16
    }
    /*================================================================
     
     End of Enum
     
     =======================================================================*/
    
    /*================================================================
     
     Function make Obstacles
     
     =======================================================================*/
   @objc func makePipes() {
        let moveChains = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        let movementAmount = arc4random() % UInt32(self.frame.height / 2)
        let moveChainsUp = SKAction.move(by: CGVector(dx: 0, dy: 300), duration: 2)
        let moveChainsDown = SKAction.move(by: CGVector(dx: 0, dy: -350), duration: 2)
        let moveChainsForever = SKAction.repeatForever(SKAction.sequence([moveChainsUp, moveChainsDown]))
        let gapHeight = dragon.size.height*3.5
        let chainOffset = CGFloat(movementAmount) - self.frame.height/4
        let chainTexture = SKTexture(imageNamed: "longchain1.png")
        let chain1 = SKSpriteNode(texture: chainTexture)
        chain1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + chainTexture.size().height/2 + gapHeight/2 + chainOffset)
        chain1.run(moveChains)
        self.addChild(chain1)
        let chain2Texture = SKTexture(imageNamed: "longchain2.png")
        let chain2 = SKSpriteNode(texture: chain2Texture)
        chain2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - chain2Texture.size().height/2 - gapHeight / 2 + chainOffset)
        chain2.run(moveChains)
        chain1.run(moveChainsForever)
        chain1.physicsBody = SKPhysicsBody(rectangleOf: chainTexture.size())
        chain1.physicsBody!.isDynamic = false
        chain1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        chain1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        chain1.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        chain1.zPosition = -1
        chain2.run(moveChainsForever)
        chain2.physicsBody = SKPhysicsBody(rectangleOf: chainTexture.size())
        chain2.physicsBody!.isDynamic = false
        chain2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        chain2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        chain2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        chain2.zPosition = -1
        self.addChild(chain2)
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + chainOffset )
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: chainTexture.size().width, height: gapHeight))
        gap.physicsBody!.isDynamic = false
        gap.run(moveChains)
        gap.run(moveChainsForever)
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        self.addChild(gap)
    
    }
    
    /*================================================================
     
     End of Function make Obstacles
     
     =======================================================================*/
    
    /*================================================================
     
     Function make Fireball at position of Dragon
     
     =======================================================================*/
    @objc func makeFireball() {
        let fireballTexture = SKTexture(imageNamed: "fireball.png")
        fireball = SKSpriteNode(texture: fireballTexture)
        fireball.position = CGPoint(x: -0.2 * self.frame.width + dragon.size.width, y: dragon.position.y)
        let movefireballForward = SKAction.move(by: CGVector(dx: self.frame.width, dy: 0), duration: 3)
        fireball.run(movefireballForward)
        fireball.physicsBody = SKPhysicsBody(rectangleOf: fireballTexture.size())
        fireball.physicsBody!.isDynamic = true
        fireball.physicsBody?.affectedByGravity = false
        fireball.physicsBody!.contactTestBitMask = ColliderType.Enemy.rawValue
        fireball.physicsBody!.categoryBitMask = ColliderType.Fire.rawValue
        fireball.physicsBody!.collisionBitMask = ColliderType.Fire.rawValue
        self.addChild(fireball)
    }
    /*================================================================
     
     End of Function to make Fireball
     
     =======================================================================*/
    
    /*================================================================
     
     Function to make Enemy automatically around the middle of the screen
     
     =======================================================================*/
   @objc func makeEnemy()
    {
        var EnemyActualY: CGFloat = 0.0
        let EnemyY = arc4random() % UInt32(self.frame.height/2)
        let EnemyTexture = SKTexture(imageNamed: "blade_1.png")
        //Make Rotating Blade
        let bladeTexture2  = SKTexture(imageNamed: "blade_2.png")
        let bladeTexture3 = SKTexture(imageNamed: "blade_3.png")
        let Bladeanimation = SKAction.animate(with: [EnemyTexture, bladeTexture2, bladeTexture3], timePerFrame: 0.08)
        let moveBladeAttack = SKAction.move(to: CGPoint(x: dragon.position.x, y: dragon.position.y), duration: 2.3)
        let makeBladeRotate = SKAction.repeatForever(Bladeanimation)
        //End of Rotating Blade
        Enemy = SKSpriteNode(texture: EnemyTexture)
        if EnemyY < UInt32(self.frame.height/4)
        {
            EnemyActualY = -2 * CGFloat(EnemyY)
        }
        else
        {
            EnemyActualY = CGFloat(EnemyY)
        }
        Enemy.position = CGPoint(x: self.frame.width, y: EnemyActualY)
        let moveEnemyBackward = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 150))
       // let moveEnemyAttack = SKAction.move(to: CGPoint(x: bird.position.x, y: bird.position.y), duration: 2.3)
       // Enemy.run(moveEnemyAttack)
        Enemy.run(moveEnemyBackward)
        Enemy.run(moveBladeAttack)
        Enemy.run(makeBladeRotate)
        Enemy.physicsBody = SKPhysicsBody(rectangleOf: EnemyTexture.size())
        Enemy.physicsBody!.isDynamic = false
        Enemy.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        Enemy.physicsBody!.categoryBitMask = ColliderType.Enemy.rawValue
        Enemy.physicsBody!.collisionBitMask = ColliderType.Enemy.rawValue
        self.addChild(Enemy)

    }
    
    /*================================================================
     
     End of Function make Enemy
     
     =======================================================================*/
    
    /*================================================================
     
     Function is called to handle contact between objects in game
     
     =======================================================================*/
    func didBegin(_ contact: SKPhysicsContact) {
        //Contact between dragon and the gap
        if (gameOver==false)
        {
            let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
            if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue
        {
         score += 1
         scoreLabel.text = String(score)
        }
        //End of dragon and the gap
                
        //Contact between fireball and enemy
    
        else if (contactMask == 24)
        {
            self.run(soundExplosion)
            
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            //Handle Explosion
            let ExplosionTexture0 = SKTexture(imageNamed: "explosion0.png")
            let ExplosionTexture1 = SKTexture(imageNamed: "explosion1.png")
            let ExplosionTexture2 = SKTexture(imageNamed: "explosion2.png")
            let ExposionEnd = SKTexture(imageNamed: "output.png")
            let animation = SKAction.animate(with: [ExplosionTexture0, ExplosionTexture1,ExplosionTexture2, ExposionEnd], timePerFrame: 0.1)
            boomExplosion = SKSpriteNode(texture: ExplosionTexture2)
            boomExplosion.position = CGPoint(x: fireball.position.x, y: fireball.position.y)
            boomExplosion.run(animation)
            self.addChild(boomExplosion)
            //End of Explosion
        }
        //End of contact
                /*================================================================
                 
                 Other contact between the dragon and other => Game Over State
                 
                 =======================================================================*/
        else
        {
        self.run(soundHit)
        self.speed = 0
        gameOver = true
        timer1.invalidate()
        timer2.invalidate()
        gameOverLabel.fontName = "Chalkduster"
        let GameOverBackground = SKSpriteNode(imageNamed: "gameOverBack.png")
        GameOverBackground.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        GameOverBackground.zPosition = 1
        self.addChild(GameOverBackground)
        if (score>highestScore)
        {
            highestScore = score
        }
        highestScoreLabel.fontName = "Chalkduster"
        highestScoreLabel.fontSize = 30
        highestScoreLabel.position = CGPoint(x : self.frame.midX , y: self.frame.midY - 80)
        highestScoreLabel.text = "Best Score: " + String(highestScore)
        highestScoreLabel.zPosition = 2
        scoreLabel.fontSize = 30
        scoreLabel.fontName = "Chalkduster"
        scoreLabel.position = CGPoint(x : self.frame.midX , y: self.frame.midY)
        scoreLabel.zPosition = 2
        scoreLabel.text = "Score: " + String(score)
        gameOverLabel.fontSize = 30
        gameOverLabel.text = "Game Over! Tap to play again."
        gameOverLabel.position = CGPoint(x : self.frame.midX, y: self.frame.midY + 80)
        gameOverLabel.zPosition = 2
        self.addChild(gameOverLabel)
        self.addChild(highestScoreLabel)
        }
        }
    }
    /*================================================================
     
      End of Function handling Object contacts
     
     =======================================================================*/
    
    /*================================================================
     
     Function is called the game app is first loaded
     
     =======================================================================*/
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.setUpgame()
    }
    
    /*================================================================
     
     Function to set up the initial state of the game
     
     =======================================================================*/
    func setUpgame()
    {
        //Promt User to tap on the screen
        TapTap.position =  CGPoint(x: self.frame.midX, y: self.frame.height/2-300)
        TapTap.fontName = "Chalkduster"
        TapTap.text = "Tap the screen to start!"
        TapTap.fontSize = 30
        self.addChild(TapTap)
        //Array Random number index to rotate background and dragon pics
        var ArrayName : [String] = []
        var randomIndexBackground: Int = 0
        let backgroundArray = ["background.png", "background1.png", "background2.png", "background4.png"]
        randomIndexBackground = Int(arc4random_uniform(4))
        let bgTexture = SKTexture(imageNamed: backgroundArray[randomIndexBackground])
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy: 0), duration: 7)
        let shiftBGAnimation = SKAction.move(by: CGVector(dx: bgTexture.size().width, dy: 0),duration: 0)
        let moveBGForever = SKAction.repeatForever(SKAction.sequence([moveBGAnimation, shiftBGAnimation]))
        var i: CGFloat = 0
        while i<3
        {
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: bgTexture.size().width * i, y: self.frame.midY)
            bg.size.height = self.frame.height
            bg.run(moveBGForever)
            bg.zPosition = -2
            self.addChild(bg)
            i += 1
        }
        var randomIndexDragon: Int = 0
        randomIndexDragon = Int(arc4random_uniform(2))
        if randomIndexDragon == 0
        {
            ArrayName = ["D1FLY_000.png", "D1FLY_001.png", "D1FLY_004.png", "D1ATTACK_005.png"]
        }
        else
        {
            ArrayName = ["D2FLY_000.png", "D2FLY_001.png", "D2FLY_004.png", "D2ATTACK_005.png"]
            
        }
        let birdTexture = SKTexture(imageNamed: ArrayName[0])
        let birdTexture2 = SKTexture(imageNamed: ArrayName[1])
        let birdTexture3 = SKTexture(imageNamed: ArrayName[2])
        let birdTexture4 = SKTexture(imageNamed: ArrayName[3])
        let animation = SKAction.animate(with: [birdTexture, birdTexture2,birdTexture3, birdTexture4], timePerFrame: 0.08)
        let makeBirdFlap = SKAction.repeatForever(animation)
        dragon = SKSpriteNode(texture: birdTexture)
        dragon.position = CGPoint(x: -0.2 * self.frame.width, y: self.frame.midY)
        dragon.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height/2)
        dragon.physicsBody!.isDynamic = false
        dragon.run(makeBirdFlap)
        dragon.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        dragon.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        dragon.physicsBody!.collisionBitMask = ColliderType.Bird.rawValue
        self.addChild(dragon)
        scoreLabel.fontName = "Chalkduster"
        scoreLabel.fontSize = 90
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height/2-130)
        self.addChild(scoreLabel)
        timer1 = Timer.scheduledTimer(timeInterval: 2.2, target: self, selector: #selector(self.makePipes), userInfo: nil, repeats: true)
        timer2 = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.makeEnemy), userInfo: nil, repeats: true)
        let ground = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height/2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody!.isDynamic=false
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        self.addChild(ground)
    }
    /*================================================================
     
     End of the game set up
     
     =======================================================================*/
    
    /*================================================================
     
     Function when user touches the screen
     
     =======================================================================*/
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(sound)
        TapTap.removeFromParent()
        if (gameOver == false)
        {
        dragon.physicsBody!.isDynamic = true
        dragon.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        dragon.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
        makeFireball()
        }
        else
        {
            gameOver = false
            score = 0
            self.speed = 1
            self.removeAllChildren()
            setUpgame()
        }
    }
    /*================================================================
     
     End of Function touches began
     
     =======================================================================*/
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
