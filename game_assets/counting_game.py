import pygame, sys, random, json, os, math
pygame.init()

ASSETS_DIR = os.path.dirname(os.path.abspath(__file__))
RESULTS_FILE = os.path.join(ASSETS_DIR, "results.json")

def load_image(name, size=None):
    path = os.path.join(ASSETS_DIR, name)
    if not os.path.exists(path):  # Try PNG/JPG fallback
        alt = name.replace(".jpg", ".png") if ".jpg" in name else name.replace(".png", ".jpg")
        if os.path.exists(os.path.join(ASSETS_DIR, alt)):
            path = os.path.join(ASSETS_DIR, alt)
    img = pygame.image.load(path).convert_alpha()
    if size: img = pygame.transform.smoothscale(img, size)
    return img

def load_sound(name):
    path = os.path.join(ASSETS_DIR, name)
    return pygame.mixer.Sound(path) if os.path.exists(path) else None

def save_results(data):
    with open(RESULTS_FILE, "w") as f: json.dump(data, f)

def load_results():
    if os.path.exists(RESULTS_FILE):
        with open(RESULTS_FILE, "r") as f:
            try: return json.load(f)
            except: return {}
    else:
        with open(RESULTS_FILE, "w") as f: json.dump({}, f)
        return {}

results = load_results()

info = pygame.display.Info()
WIDTH, HEIGHT = max(480, info.current_w//2), max(800, info.current_h//2)
screen = pygame.display.set_mode((WIDTH, HEIGHT), pygame.RESIZABLE)
pygame.display.set_caption("Bucket Ball Toss")
clock = pygame.time.Clock()

PALETTE = [(255,99,71),(144,238,144),(135,206,250),(255,255,102),
           (221,160,221),(255,182,193),(173,216,230),(255,228,181)]
BG_COLOR = (240,248,255)

bg_image = load_image("bg.jpg")
bg2_image = load_image("bg2.png")  # PNG is now supported automatically
bucket_image = load_image("bucket.png")
pop_sound = load_sound("pop.mp3")
cheer_sound = load_sound("cheers.mp3")

class Button:
    def __init__(self, rect, text, font, bg=(255,255,255), fg=(0,0,0)):
        self.rect = pygame.Rect(rect); self.text = text
        self.font = font; self.bg = bg; self.fg = fg
    def draw(self, surf):
        pygame.draw.rect(surf, self.bg, self.rect, border_radius=16)
        pygame.draw.rect(surf, (0,0,0), self.rect, 3, border_radius=16)
        txt = self.font.render(self.text, True, self.fg)
        surf.blit(txt, (self.rect.centerx - txt.get_width()//2,
                        self.rect.centery - txt.get_height()//2))
    def is_clicked(self, pos): return self.rect.collidepoint(pos)

class Confetti:
    def __init__(self, x, y, screen_w, screen_h):
        self.particles = []
        for _ in range(80):
            angle = random.uniform(-math.pi/2-1.0, -math.pi/2+1.0)
            speed = random.uniform(2,8)
            vx, vy = math.cos(angle)*speed, math.sin(angle)*speed
            size = random.randint(4,10)
            color = random.choice(PALETTE)
            self.particles.append([x,y,vx,vy,size,color,255])
    def update(self):
        for p in self.particles[:]:
            p[0]+=p[2]; p[1]+=p[3]; p[3]+=0.25
            p[6]-=4
            if p[1]>HEIGHT+50 or p[0]<-50 or p[0]>WIDTH+50 or p[6]<=0:
                try: self.particles.remove(p)
                except: pass
    def draw(self, surf):
        for p in self.particles:
            s = pygame.Surface((p[4],p[4]), pygame.SRCALPHA)
            s.fill((*p[5], max(0,min(255,int(p[6])))))
            surf.blit(s, (int(p[0]), int(p[1])))

class Ball:
    def __init__(self,pos,radius,color):
        self.pos=list(pos); self.radius=radius; self.color=color
        self.dragging=False; self.offset=(0,0); self.scale=0.1
    def draw(self,surf):
        r=int(self.radius*self.scale)
        if r>0:
            pygame.draw.circle(surf,self.color,(int(self.pos[0]),int(self.pos[1])),r)
            pygame.draw.circle(surf,(0,0,0),(int(self.pos[0]),int(self.pos[1])),r,2)
        if self.scale<1: self.scale=min(1,self.scale+0.05)
    def is_hit(self,point):
        dx=point[0]-self.pos[0]; dy=point[1]-self.pos[1]
        return dx*dx+dy*dy<=self.radius*self.radius

class Game:
    def __init__(self): self.reset_all()
    def reset_all(self):
        self.level=1; self.time_limit=30; self.base_total=5
        self.spawn_delay=1400; self.score=0; self.balls=[]
        self.last_spawn=pygame.time.get_ticks(); self.state="menu"
        self.selected_ball=None; self.start_ticks=None; self.confetti=None
        self.best_scores=results.get("best",{}); self.prev_score=0
        self.sound_on=True
    def layout(self,w,h):
        self.W,self.H=w,h
        self.radius=max(16,int(w*0.045))
        self.bucket_w=int(w*0.28); self.bucket_h=int(h*0.12)
        self.bucket_x=w//2-self.bucket_w//2; self.bucket_y=h-self.bucket_h-int(h*0.03)
        self.hud_font=pygame.font.SysFont("Comic Sans MS",max(18,int(w*0.03)))
        self.title_font=pygame.font.SysFont("Comic Sans MS",max(24,int(w*0.05)))
        self.button_font=pygame.font.SysFont("Comic Sans MS",max(18,int(w*0.03)))

        self.start_button=Button((w//2-140,h//2+40,280,64),"Start Game",self.button_font)
        self.sound_button=Button((w//2-140,h//2+120,280,50),"Sound: ON",self.button_font,bg=(230,230,250))

        # Button positions (center column layout)
        center_x=w//2-75
        self.home_button=Button((center_x,h//2+80,150,60),"Home",self.button_font)
        self.next_button=Button((center_x,h//2+150,150,60),"Next Level",self.button_font,bg=(200,255,200))
        self.retry_button=Button((center_x,h//2+220,150,60),"Retry",self.button_font,bg=(255,220,220))
        self.exit_button=Button((center_x,h//2+290,150,60),"Exit",self.button_font,bg=(255,180,180))

        self.bucket_img=pygame.transform.smoothscale(bucket_image,(self.bucket_w,self.bucket_h)) if bucket_image else None
    def start_level(self):
        self.score=0; self.balls.clear()
        self.last_spawn=pygame.time.get_ticks()
        self.start_ticks=pygame.time.get_ticks()
        self.time_limit=max(8,30-(self.level-1)*3)
        self.spawn_delay=max(400,1400-(self.level-1)*180)
        self.total_balls=self.base_total+(self.level-1)*3
        self.extra_bucket=self.level>=3
        self.state="playing"
    def spawn_ball(self):
        x=random.randint(self.radius,self.W-self.radius)
        y=random.randint(self.radius,int(self.H*0.28))
        radius=random.randint(int(self.radius*0.8),int(self.radius*1.2)) if self.level>=4 else self.radius
        self.balls.append(Ball((x,y),radius,random.choice(PALETTE)))
    def update(self):
        now=pygame.time.get_ticks()
        if self.state=="playing":
            seconds=self.time_limit-(now-self.start_ticks)//1000
            if seconds<=0:
                self.state="game_over"; self.prev_score=self.score
                self.save_if_best(); return
            if len(self.balls)<self.total_balls and now-self.last_spawn>self.spawn_delay:
                self.spawn_ball(); self.last_spawn=now
        if self.state=="level_complete" and self.confetti: self.confetti.update()
    def draw(self,surf):
        if self.state=="menu" and bg_image:
            surf.blit(pygame.transform.smoothscale(bg_image,(self.W,self.H)),(0,0))
        elif self.state=="playing" and bg2_image:
            surf.blit(pygame.transform.smoothscale(bg2_image,(self.W,self.H)),(0,0))
        else: surf.fill(BG_COLOR)

        if self.state=="menu":
            title=self.title_font.render("Bucket Ball Toss",True,(20,20,60))
            surf.blit(title,(self.W//2-title.get_width()//2,self.H//6))
            instr=self.hud_font.render("Drag balls into the bucket before time runs out!",True,(30,30,30))
            surf.blit(instr,(self.W//2-instr.get_width()//2,self.H//6+60))
            prev=self.hud_font.render(f"Best Level: {self.best_scores.get('level',0)} | Best Score: {self.best_scores.get('score',0)}",True,(20,50,20))
            surf.blit(prev,(self.W//2-prev.get_width()//2,self.H//6+100))
            self.start_button.draw(surf)
            self.sound_button.text="Sound: ON" if self.sound_on else "Sound: OFF"
            self.sound_button.draw(surf)

        elif self.state=="playing":
            for b in self.balls: b.draw(surf)
            if self.bucket_img: surf.blit(self.bucket_img,(self.bucket_x,self.bucket_y))
            else: pygame.draw.rect(surf,(150,75,0),(self.bucket_x,self.bucket_y,self.bucket_w,self.bucket_h),border_radius=14)
            if self.extra_bucket:
                surf.blit(self.bucket_img,(self.bucket_x-self.bucket_w-30,self.bucket_y))
            seconds=self.time_limit-(pygame.time.get_ticks()-self.start_ticks)//1000
            timer_bar_w=int((seconds/self.time_limit)*(self.W-40))
            pygame.draw.rect(surf,(255,100,100),(20,20,timer_bar_w,12),border_radius=6)
            scoretxt=self.hud_font.render(f"Score: {self.score}/{self.total_balls}",True,(0,0,0))
            leveltxt=self.hud_font.render(f"Level {self.level}",True,(0,0,0))
            surf.blit(scoretxt,(20,40)); surf.blit(leveltxt,(self.W-leveltxt.get_width()-20,40))

        elif self.state=="level_complete":
            msg=self.title_font.render("Level Complete!",True,(10,120,10))
            surf.blit(msg,(self.W//2-msg.get_width()//2,self.H//3))
            sc=self.hud_font.render(f"Collected: {self.prev_score}",True,(0,0,0))
            surf.blit(sc,(self.W//2-sc.get_width()//2,self.H//3+60))
            self.home_button.draw(surf); self.next_button.draw(surf); self.exit_button.draw(surf)
            if self.confetti: self.confetti.draw(surf)

        elif self.state=="game_over":
            msg=self.title_font.render("Time's up! Try Again",True,(180,20,20))
            surf.blit(msg,(self.W//2-msg.get_width()//2,self.H//3))
            sc=self.hud_font.render(f"Collected: {self.prev_score}",True,(0,0,0))
            surf.blit(sc,(self.W//2-sc.get_width()//2,self.H//3+60))
            self.retry_button.draw(surf); self.home_button.draw(surf); self.exit_button.draw(surf)

    def handle_event(self,event):
        if event.type==pygame.VIDEORESIZE: self.layout(event.w,event.h)
        if self.state=="menu" and event.type==pygame.MOUSEBUTTONDOWN:
            if self.start_button.is_clicked(event.pos): self.start_level()
            elif self.sound_button.is_clicked(event.pos): self.sound_on=not self.sound_on
        elif self.state=="playing":
            if event.type==pygame.MOUSEBUTTONDOWN:
                for b in reversed(self.balls):
                    if b.is_hit(event.pos):
                        b.dragging=True; b.offset=(b.pos[0]-event.pos[0],b.pos[1]-event.pos[1])
                        self.selected_ball=b; break
            if event.type==pygame.MOUSEBUTTONUP and self.selected_ball:
                self.selected_ball.dragging=False
                inside_main=self.bucket_x<self.selected_ball.pos[0]<self.bucket_x+self.bucket_w and self.bucket_y<self.selected_ball.pos[1]<self.bucket_y+self.bucket_h
                inside_extra=self.extra_bucket and self.bucket_x-self.bucket_w-30<self.selected_ball.pos[0]<self.bucket_x-30 and self.bucket_y<self.selected_ball.pos[1]<self.bucket_y+self.bucket_h
                if inside_main or inside_extra:
                    if self.selected_ball in self.balls: self.balls.remove(self.selected_ball)
                    self.score+=1
                    if pop_sound and self.sound_on: pop_sound.play()
                    if self.score>=self.total_balls:
                        self.prev_score=self.score; self.level+=1
                        self.save_if_best(); self.state="level_complete"
                        self.confetti=Confetti(self.W//2,self.H//3,self.W,self.H)
                        if cheer_sound and self.sound_on: cheer_sound.play()
                self.selected_ball=None
            if event.type==pygame.MOUSEMOTION and self.selected_ball and self.selected_ball.dragging:
                self.selected_ball.pos[0]=event.pos[0]+self.selected_ball.offset[0]
                self.selected_ball.pos[1]=event.pos[1]+self.selected_ball.offset[1]
        elif self.state=="level_complete" and event.type==pygame.MOUSEBUTTONDOWN:
            if self.home_button.is_clicked(event.pos):
                if cheer_sound: cheer_sound.stop()
                self.state="menu"
            if self.next_button.is_clicked(event.pos):
                if cheer_sound: cheer_sound.stop()
                self.start_level()
            if self.exit_button.is_clicked(event.pos): pygame.quit(); sys.exit()
        elif self.state=="game_over" and event.type==pygame.MOUSEBUTTONDOWN:
            if self.retry_button.is_clicked(event.pos): self.start_level()
            if self.home_button.is_clicked(event.pos): self.state="menu"
            if self.exit_button.is_clicked(event.pos): pygame.quit(); sys.exit()
    def save_if_best(self):
        best_level=self.best_scores.get("level",0)
        best_score=self.best_scores.get("score",0)
        if self.level>best_level or (self.level==best_level and self.prev_score>best_score):
            self.best_scores["level"]=self.level; self.best_scores["score"]=self.prev_score
            results["best"]=self.best_scores; save_results(results)

game=Game(); game.layout(WIDTH,HEIGHT)
while True:
    for event in pygame.event.get():
        if event.type==pygame.QUIT: pygame.quit(); sys.exit()
        game.handle_event(event)
    game.update(); game.draw(screen)
    pygame.display.flip(); clock.tick(60)
