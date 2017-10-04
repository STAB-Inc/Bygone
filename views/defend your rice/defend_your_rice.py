import pygame
import random
import time
from pygame.locals import *

# Define some colors
BLACK = (  0,   0,   0)
WHITE = (255, 255, 255)
RED   = (255,   0,   0)
GREY  = (160, 160, 160)

# Initialize Pygame
pygame.init()
 
# Set the height and width of the screen
screen_width = 800
screen_height = 600
screen = pygame.display.set_mode([screen_width, screen_height])

#Initializing the game clock
clock = pygame.time.Clock()

#The first sprite class for the enemy
class Hobo(pygame.sprite.Sprite):
    """
    This class represents the ball.
    It derives from the "Sprite" class in Pygame.
    """
    def __init__(self, img):
        """ Constructor. Pass in the color of the block,
        and its x and y position. """
 
        # Call the parent class (Sprite) constructor
        super().__init__()
 
        # Create an image of the sprite
        self.image = img
 
        # Fetch the rectangle object that has the dimensions of the image
        # image.

        self.rect = self.image.get_rect()
        self.speed = 2
    def reset_pos(self):
        #Spawning position"
        self.rect.y = -100
        self.rect.x = random.randrange(64,736)

    def update(self):
        #Call the global score variable
        global rice
 
        # Move block down
        self.rect.y += self.speed
 
        # If block is too far down, reset to top of screen.
        if self.rect.y > 700:
            self.reset_pos()
            rice -= 1
    #Animation to make sprite look like its moving
    def step_right(self):
        self.image = (pygame.image.load('hobo_right.png'))
    def step_left(self):
        self.image = (pygame.image.load('hobo_left.png'))

#Second sprite of dead hobo
class deadhobo(pygame.sprite.Sprite):
    def __init__(self, x, y):
        super().__init__()
        self.image = self.image = (pygame.image.load('dead_hobo.png'))
        self.rect = self.image.get_rect()
        self.rect.x = x
        self.rect.y = y
 
#Creating counter for score and lives
def rice_counter(count):
    font = pygame.font.SysFont(None, 25)
    text = font.render("Bags of rice: "+str(count), True, RED)
    screen.blit(text,(10,10))

def things_killed(count):
    font = pygame.font.SysFont(None, 25)
    text = font.render("Hobos killed: "+str(count), True, RED)
    screen.blit(text,(10,35))

#A function that displays score on center of screen
def Lose(score):
    font = pygame.font.SysFont(None, 144)
    text = font.render("You killed: "+str(score), True, BLACK)
    screen.blit(text,(75, 200))

#A function to create text object
def text_objects(text, font):
    textSurface = font.render(text, True, BLACK)
    return textSurface, textSurface.get_rect()

#A function that makes a button which execute an action
def button(msg,x,y,w,h,ic,ac,action=None):
    mouse = pygame.mouse.get_pos()
    click = pygame.mouse.get_pressed()
    print(click)
    if x+w > mouse[0] > x and y+h > mouse[1] > y:
        pygame.draw.rect(screen, ac,(x,y,w,h))

        if click[0] == 1:
            action()
            
    else:
        pygame.draw.rect(screen, ic,(x,y,w,h))

    smallText = pygame.font.SysFont("comicsansms",20)
    textSurf, textRect = text_objects(msg, smallText)
    textRect.center = ( (x+(w/2)), (y+(h/2)) )
    screen.blit(textSurf, textRect)

#Generating a list of sound clips
sounds = []
sounds.append(pygame.mixer.Sound('splatter.OGG'))
sounds.append(pygame.mixer.Sound('game_music.OGG'))
sounds.append(pygame.mixer.Sound('gunshot.OGG'))

#PLaying the background music
sounds[1].play()    

#Intro function
def game_intro():
    global intro
    intro = True
    back_img = pygame.image.load("start_back.png")
    while intro:
        pygame.mouse.set_visible(True)
        for event in pygame.event.get():
            print(event)
            if event.type == pygame.QUIT:
                pygame.quit()
                quit()
                
        #Creating Title
        screen.fill(WHITE)
        screen.blit(back_img,(0,0))
        largeText = pygame.font.Font('freesansbold.ttf',72)
        TextSurf, TextRect = text_objects("Defend your Rice", largeText)
        TextRect.center = ((screen_width/2)-50,(screen_height/2)-250)
        screen.blit(TextSurf, TextRect)

        #Creating buttons
        button("SHOOT",150,350,100,50,GREY,RED,game_loop)
        button("Help",350,350,100,50,GREY,RED,help)
        button("Quit",550,375,100,50,GREY,RED,quit)

        pygame.display.update()
        clock.tick(15)

#Help Screen function
def help():
    global intro
    intro = True
    back_img = pygame.image.load("help_back.png")
    while intro:
        pygame.mouse.set_visible(True)
        for event in pygame.event.get():
            print(event)
            if event.type == pygame.QUIT:
                pygame.quit()
                quit()
                
        screen.fill(WHITE)
        screen.blit(back_img,(0,0))
        largeText = pygame.font.Font('freesansbold.ttf',72)
        TextSurf, TextRect = text_objects("Help", largeText)
        TextRect.center = ((screen_width/2)-200,(screen_height/2)-250)
        screen.blit(TextSurf, TextRect)
        largeText = pygame.font.Font('freesansbold.ttf',24)
        TextSurf, TextRect = text_objects("Hobos are raiding your stockpile", largeText)
        TextRect.center = ((screen_width/2)-200,(screen_height/2)-175)
        screen.blit(TextSurf, TextRect)
        largeText = pygame.font.Font('freesansbold.ttf',24)
        TextSurf, TextRect = text_objects("of rice. Don't let them take any!", largeText)
        TextRect.center = ((screen_width/2)-200,(screen_height/2)-150)
        screen.blit(TextSurf, TextRect)
        largeText = pygame.font.Font('freesansbold.ttf',24)
        TextSurf, TextRect = text_objects("Click on them to shoot", largeText)
        TextRect.center = ((screen_width/2)-200,(screen_height/2)-100)
        screen.blit(TextSurf, TextRect)
        largeText = pygame.font.Font('freesansbold.ttf',24)
        TextSurf, TextRect = text_objects("Be careful of recoil", largeText)
        TextRect.center = ((screen_width/2)-200,(screen_height/2)-75)
        screen.blit(TextSurf, TextRect)
        largeText = pygame.font.Font('freesansbold.ttf',24)
        TextSurf, TextRect = text_objects("Kill as many as you can before", largeText)
        TextRect.center = ((screen_width/2)-200,(screen_height/2)-50)
        screen.blit(TextSurf, TextRect)
        largeText = pygame.font.Font('freesansbold.ttf',24)
        TextSurf, TextRect = text_objects("they get to you", largeText)
        TextRect.center = ((screen_width/2)-200,(screen_height/2)-25)
        screen.blit(TextSurf, TextRect)
        largeText = pygame.font.Font('freesansbold.ttf',24)
        TextSurf, TextRect = text_objects("Be careful they are very quiet", largeText)
        TextRect.center = ((screen_width/2)-200,(screen_height/2))
        screen.blit(TextSurf, TextRect)
        largeText = pygame.font.Font('freesansbold.ttf',24)
        TextSurf, TextRect = text_objects("and may sneak past you", largeText)
        TextRect.center = ((screen_width/2)-200,(screen_height/2)+25)
        screen.blit(TextSurf, TextRect)
        button("Back",150,450,100,50,GREY,RED,game_intro)
        pygame.display.update()
        clock.tick(15)
# -------- Main Program Loop -----------

#Game Function
def game_loop():
    #Setting score and life
    global rice
    score = 0
    rice = 10

    #A list for each type of sprite
    hobo_list = pygame.sprite.Group()
    scope_list = pygame.sprite.Group()
    dead_list = pygame.sprite.Group()

    # This is a list of every sprite. 
    # All enemies and the scope sprite as well.
    all_sprites_list = pygame.sprite.Group()
    scope = Hobo(pygame.image.load('scope.png'))
    detector = Hobo(pygame.image.load('detector.png'))
    all_sprites_list.add(detector)
    all_sprites_list.add(scope)
    scope_list.add(detector)
    scope_list.add(scope)

    rice_paddy = pygame.image.load('rice_paddy.png') 

    #Setting timers
    pygame.time.set_timer(USEREVENT+1, 3000)
    pygame.time.set_timer(USEREVENT+2, 100)
    pygame.time.set_timer(USEREVENT+3, 5000)

    # Loop until the user clicks the close button.
    done = False

    #To indicate whether enemy sprites are on the left or right foot
    step = True

    #To indicate whether the player has lost yet
    lose = 0

    pygame.mouse.set_visible(False)
    while not done:
        for event in pygame.event.get(): 
            if event.type == pygame.QUIT: 
                done = True 
            if event.type == pygame.USEREVENT + 1:
                for i in range(5):
                    # This represents an enemy
                    hobo = Hobo(pygame.image.load('hobo.png'))
 
                    # Set a random location for the enemy
                    hobo.rect.x = random.randrange(32,750)
                    hobo.rect.y = 0
 
                    # Add the block to the list of objects
                    hobo_list.add(hobo)
                    all_sprites_list.add(hobo)

            #Using a timer to animate enemy
            if event.type == pygame.USEREVENT + 2:
                if step == True:
                    for hobo in hobo_list:
                        hobo.step_left()
                    step = False
                else:
                    for hobo in hobo_list:
                        hobo.step_right()
                    step = True
            #Clear all dead enemies after a certain time
            if event.type == pygame.USEREVENT + 3:
                dead_list.empty()
            if event.type == pygame.MOUSEBUTTONDOWN:
                sounds[2].play()
                #See if the detector has collided with anything in the enemy list
                hobos_hit_list = pygame.sprite.spritecollide(detector, hobo_list, False)
                for i in range(0,50):
                    pygame.mouse.set_pos(pos[0],pos[1]-i)
                # Check the list of collisions.
                for hobo in hobos_hit_list:
                    deadHobo = deadhobo(hobo.rect.x, hobo.rect.y)
                    dead_list.add(deadHobo)
                    all_sprites_list.add(deadHobo)
                    all_sprites_list.remove(hobo)
                    hobo_list.remove(hobo)
                    sounds[0].play()
                    score += 1
        # Clear the screen
        screen.fill(WHITE)
        all_sprites_list.update()
        # Get the current mouse position. This returns the position
        # as a list of two numbers.
        pos = pygame.mouse.get_pos()
 
        # Fetch the x and y out of the list,
        # Set the player object to the mouse location
        scope.rect.x = pos[0]-900
        scope.rect.y = pos[1]-800
        detector.rect.x = pos[0]-8
        detector.rect.y = pos[1]-8

        screen.blit(rice_paddy,(0,0))
        # Draw all the spites
        dead_list.draw(screen)
        hobo_list.draw(screen)
    
        if rice < 1:
            Lose(score)
            scope_list.empty()
            lose = True

        scope_list.draw(screen)
        rice_counter(rice)
        things_killed(score)
        #Update the screen with what we've drawn
        pygame.display.update()
        if lose is True:
            pygame.time.delay(4000)
            done = True
            game_intro()
        # Limit to 60 frames per second
        clock.tick(60)

#Initiate the intro screen
game_intro()
pygame.quit()
quit()