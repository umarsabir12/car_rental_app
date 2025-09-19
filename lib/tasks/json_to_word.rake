require 'caracal'

namespace :attachment do
  desc "Convert JSON attachment assessment to Word document"
  task :json_to_word => :environment do
    # Your JSON data (you could also load from a file)
    json_data = {
        "forced_choice": [
          {
            "block_id": "FC1",
            "prompt": "Your partner pauses before replying to your text.",
            "options": {
              "A": {
                "text": "I assume they’re busy and wait patiently.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I worry I may have said something wrong.",
                "subtype": "NURTURING ANXIOUS"
              },
              "C": {
                "text": "I accept it quietly, not wanting to pressure them.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "D": {
                "text": "Once they respond I ignore them.",
                "subtype": "MANIPULATIVE AVOIDANT"
              }
            }
          },
          {
            "block_id": "FC2",
            "prompt": "A friend cancels dinner at the last minute.",
            "options": {
              "A": {
                "text": "I think about all the ways they owe me an apology.",
                "subtype": "TOXIC ANXIOUS"
              },
              "B": {
                "text": "I nod quietly, unsure how to feel.",
                "subtype": "QUIET DISORGANIZED"
              },
              "C": {
                "text": "I remind myself it’s okay and trust they’ll make it right.",
                "subtype": "REMADE SECURE"
              },
              "D": {
                "text": "I call them firmly and ask why they canceled.",
                "subtype": "LOUD DISORGANIZED"
              }
            }
          },
          {
            "block_id": "FC3",
            "prompt": "A coworker takes credit for your idea in a meeting.",
            "options": {
              "A": {
                "text": "I hold back and let it go.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "B": {
                "text": "I calmly point out it was my idea.",
                "subtype": "SECURE"
              },
              "C": {
                "text": "I let it slide, then hint later that I’m upset.",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "D": {
                "text": "I withdraw from the room, too stunned to respond.",
                "subtype": "QUIET DISORGANIZED"
              }
            }
          },
          {
            "block_id": "FC4",
            "prompt": "Your partner praises your independence in front of others.",
            "options": {
              "A": {
                "text": "I feel grateful—my past insecurities are gone.",
                "subtype": "REMADE SECURE"
              },
              "B": {
                "text": "I appreciate it, but worry they might grow tired of me eventually.",
                "subtype": "NURTURING ANXIOUS"
              },
              "C": {
                "text": "I'm happy but inside I feel very unstable and worry that they will take advantage of me.",
                "subtype": "LOUD DISORGANIZED"
              },
              "D": {
                "text": "I feel frustrated because they're using independence as an excuse not to meet my needs.",
                "subtype": "TOXIC ANXIOUS"
              }
            }
          },
          {
            "block_id": "FC5",
            "prompt": "A friend invites you to an event you don’t really want to attend.",
            "options": {
              "A": {
                "text": "I tell them that I'm busy even if I'm not.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "B": {
                "text": "I say yes even though I don't want to but I want them to be happy.",
                "subtype": "QUIET DISORGANIZED"
              },
              "C": {
                "text": "I politely decline and suggest an alternative plan.",
                "subtype": "SECURE"
              },
              "D": {
                "text": "I ignore the invite and plan to tell them that I forgot.",
                "subtype": "MANIPULATIVE AVOIDANT"
              }
            }
          },
          {
            "block_id": "FC6",
            "prompt": "Someone laughs at a story you told in a way you find critical, unkind or disapproving.",
            "options": {
              "A": {
                "text": "I raise my voice and ask, “What the heck does THAT mean?”",
                "subtype": "LOUD DISORGANIZED"
              },
              "B": {
                "text": "I worry my story was bad or offensive somehow and explain more.",
                "subtype": "NURTURING ANXIOUS"
              },
              "C": {
                "text": "I ask for an apology and explain how their behavior offended me.",
                "subtype": "TOXIC ANXIOUS"
              },
              "D": {
                "text": "I remember how I used to panic and now just smile.",
                "subtype": "REMADE SECURE"
              }
            }
          },
          {
            "block_id": "FC7",
            "prompt": "Your partner says they need some space.",
            "options": {
              "A": {
                "text": "I say, “Okay, take your time—no rush.”",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I send a message later just to stay connected.",
                "subtype": "NURTURING ANXIOUS"
              },
              "C": {
                "text": "I become distant, hoping they’ll notice.",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "D": {
                "text": "I keep my feelings to myself so they don’t feel guilty.",
                "subtype": "ETHICAL AVOIDANT"
              }
            }
          },
          {
            "block_id": "FC8",
            "prompt": "You overhear someone gossiping about you.",
            "options": {
              "A": {
                "text": "I replay it in my head and feel guilty.",
                "subtype": "NURTURING ANXIOUS"
              },
              "B": {
                "text": "I speak up so they know I heard them.",
                "subtype": "LOUD DISORGANIZED"
              },
              "C": {
                "text": "I think of a plan to make the playing field even.",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "D": {
                "text": "I realize that I need to vet people better.",
                "subtype": "REMADE SECURE"
              }
            }
          },
          {
            "block_id": "FC9",
            "prompt": "A friend shares something personal, then becomes distant.",
            "options": {
              "A": {
                "text": "I gently check in, remembering how I used to panic.",
                "subtype": "REMADE SECURE"
              },
              "B": {
                "text": "I say, “I’m here if you want to talk.”",
                "subtype": "SECURE"
              },
              "C": {
                "text": "I accept it quietly, not wanting to pressure them.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "D": {
                "text": "I feel some anger and ask them if they’re mad at me.",
                "subtype": "LOUD DISORGANIZED"
              }
            }
          },
          {
            "block_id": "FC10",
            "prompt": "Your partner calls you unexpectedly during a meeting.",
            "options": {
              "A": {
                "text": "I let it go to voicemail and call back afterward. Work takes priority.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "B": {
                "text": "I interrupt the meeting to check in right away.",
                "subtype": "NURTURING ANXIOUS"
              },
              "C": {
                "text": "I stay focused on the meeting, then text them to let them know it’s inappropriate to contact me at work.",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "D": {
                "text": "I finish the meeting, then return their call.",
                "subtype": "SECURE"
              }
            }
          },
          {
            "block_id": "FC11",
            "prompt": "Someone compliments your work in front of others.",
            "options": {
              "A": {
                "text": "I thank them and trust they mean it.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I think, “They must want something from me.”",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "C": {
                "text": "I feel they owe me a thank-you in return.",
                "subtype": "TOXIC ANXIOUS"
              },
              "D": {
                "text": "I recall I used to doubt compliments and feel proud I’ve changed.",
                "subtype": "REMADE SECURE"
              }
            }
          },
          {
            "block_id": "FC12",
            "prompt": "A friend teases you in public.",
            "options": {
              "A": {
                "text": "I feel embarrassed but laugh to keep the peace.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "B": {
                "text": "I tell them I didn’t appreciate that comment.",
                "subtype": "LOUD DISORGANIZED"
              },
              "C": {
                "text": "I freeze inside and say nothing.",
                "subtype": "QUIET DISORGANIZED"
              },
              "D": {
                "text": "I apologize, worrying I was oversensitive.",
                "subtype": "NURTURING ANXIOUS"
              }
            }
          },
          {
            "block_id": "FC13",
            "prompt": "Your partner texts: “We need to talk.”",
            "options": {
              "A": {
                "text": "I prepare myself to listen calmly.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I start to worry and ask firmly, “What’s going on?”",
                "subtype": "LOUD DISORGANIZED"
              },
              "C": {
                "text": "I panic that I did something wrong.",
                "subtype": "TOXIC ANXIOUS"
              },
              "D": {
                "text": "I remind myself I can handle this better now.",
                "subtype": "REMADE SECURE"
              }
            }
          },
          {
            "block_id": "FC14",
            "prompt": "In a group, someone interrupts your story.",
            "options": {
              "A": {
                "text": "I smile and wait until I get another chance.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I wait for a chance to interrupt and steal the focus back.",
                "subtype": "LOUD DISORGANIZED"
              },
              "C": {
                "text": "I stay quiet to avoid conflict.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "D": {
                "text": "I assume no one wanted to hear my story, anyway, and let it go.",
                "subtype": "QUIET DISORGANIZED"
              }
            }
          },
          {
            "block_id": "FC15",
            "prompt": "Your partner forgets your anniversary.",
            "options": {
              "A": {
                "text": "I say, “That’s okay - we’ll celebrate later.”",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I feel they owe me a sincere apology.",
                "subtype": "TOXIC ANXIOUS"
              },
              "C": {
                "text": "I stay silent, too hurt to speak.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "D": {
                "text": "I remind them calmly how much it meant to me.",
                "subtype": "REMADE SECURE"
              }
            }
          },
          {
            "block_id": "FC16",
            "prompt": "A friend shares sad news but you’re busy.",
            "options": {
              "A": {
                "text": "I set a time to discuss the news so they feel cared for.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I reschedule everything to be there for them.",
                "subtype": "NURTURING ANXIOUS"
              },
              "C": {
                "text": "I offer quick support so that I don’t get too distracted.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "D": {
                "text": "I do something thoughtful so they know I care.",
                "subtype": "LOUD DISORGANIZED"
              }
            }
          },
          {
            "block_id": "FC17",
            "prompt": "After an argument, your partner needs time alone.",
            "options": {
              "A": {
                "text": "I trust they’ll come back when they’re ready.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I panic and send another message.",
                "subtype": "NURTURING ANXIOUS"
              },
              "C": {
                "text": "I wait quietly, hoping they’ll ask how I feel.",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "D": {
                "text": "I’m surprised that I’m handling this better than before.",
                "subtype": "REMADE SECURE"
              }
            }
          },
          {
            "block_id": "FC18",
            "prompt": "You overhear someone gossiping about you again.",
            "options": {
              "A": {
                "text": "I stay silent, too stunned to respond.",
                "subtype": "QUIET DISORGANIZED"
              },
              "B": {
                "text": "I respond firmly so they know I heard them.",
                "subtype": "LOUD DISORGANIZED"
              },
              "C": {
                "text": "I step away to avoid making a scene.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "D": {
                "text": "I tell myself it’s probably a misunderstanding.",
                "subtype": "SECURE"
              }
            }
          },
          {
            "block_id": "FC19",
            "prompt": "Your partner compliments your problem-solving.",
            "options": {
              "A": {
                "text": "I accept it without overthinking.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I wonder what they want from me now.",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "C": {
                "text": "I worry it’s a test and I’ll fail.",
                "subtype": "NURTURING ANXIOUS"
              },
              "D": {
                "text": "I feel proud because I once doubted myself.",
                "subtype": "REMADE SECURE"
              }
            }
          },
          {
            "block_id": "FC20",
            "prompt": "Your partner surprises you with a thoughtful gift.",
            "options": {
              "A": {
                "text": "I accept it gratefully without question.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I wonder what they expect from me next.",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "C": {
                "text": "I feel shocked that someone would want to get me something.",
                "subtype": "QUIET DISORGANIZED"
              },
              "D": {
                "text": "I feel hurt that they waited so long to do something nice.",
                "subtype": "TOXIC ANXIOUS"
              }
            }
          },
          {
            "block_id": "FC21",
            "prompt": "A friend asks why you didn’t help earlier.",
            "options": {
              "A": {
                "text": "I apologize and explain honestly.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I think they owe me something for everything I’ve done.",
                "subtype": "TOXIC ANXIOUS"
              },
              "C": {
                "text": "I hold back so they don’t feel guilty.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "D": {
                "text": "I freeze, unsure how to respond.",
                "subtype": "QUIET DISORGANIZED"
              }
            }
          },
          {
            "block_id": "FC22",
            "prompt": "A friend posts something online you dislike.",
            "options": {
              "A": {
                "text": "I message calmly to share my feelings.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I post a strong comment so they notice.",
                "subtype": "LOUD DISORGANIZED"
              },
              "C": {
                "text": "I delete my comment, worrying I’m too sensitive.",
                "subtype": "NURTURING ANXIOUS"
              },
              "D": {
                "text": "I let it go rather than argue.",
                "subtype": "ETHICAL AVOIDANT"
              }
            }
          },
          {
            "block_id": "FC23",
            "prompt": "Your partner compliments your independence again.",
            "options": {
              "A": {
                "text": "I say thank you without overthinking.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I wonder what they want from me next.",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "C": {
                "text": "I worry it’s a test to see if I measure up.",
                "subtype": "NURTURING ANXIOUS"
              },
              "D": {
                "text": "I recall my old doubts and feel proud of my growth.",
                "subtype": "REMADE SECURE"
              }
            }
          },
          {
            "block_id": "FC24",
            "prompt": "Your partner shares a personal secret.",
            "options": {
              "A": {
                "text": "I think, “I used to cling, but now I can listen.”",
                "subtype": "REMADE SECURE"
              },
              "B": {
                "text": "I feel honored and try to comfort them.",
                "subtype": "NURTURING ANXIOUS"
              },
              "C": {
                "text": "I keep it to myself, not wanting to get too involved.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "D": {
                "text": "I feel relieved they finally trusted me with their secrets, now I’m not so vulnerable.",
                "subtype": "LOUD DISORGANIZED"
              }
            }
          },
          {
            "block_id": "FC25",
            "prompt": "Your partner says, “Let’s take a break for a bit.”",
            "options": {
              "A": {
                "text": "I respect their request and trust we’ll reconnect.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I panic and send another message.",
                "subtype": "NURTURING ANXIOUS"
              },
              "C": {
                "text": "I wait quietly, hoping they’ll ask me how I feel.",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "D": {
                "text": "I remind myself I handled this better than before.",
                "subtype": "REMADE SECURE"
              }
            }
          },
          {
            "block_id": "FC26",
            "prompt": "A friend compliments your work ethic.",
            "options": {
              "A": {
                "text": "I enjoy it and move on.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I suspect they want something from me.",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "C": {
                "text": "I feel uncertain and keep my reaction to myself.",
                "subtype": "QUIET DISORGANIZED"
              },
              "D": {
                "text": "I feel they owe me acknowledgement for all I do.",
                "subtype": "TOXIC ANXIOUS"
              }
            }
          },
          {
            "block_id": "FC27",
            "prompt": "Your partner cancels plans again without warning.",
            "options": {
              "A": {
                "text": "I gently ask if they’re okay and move on.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I worry they’re punishing me by ignoring me.",
                "subtype": "NURTURING ANXIOUS"
              },
              "C": {
                "text": "I assume they’ve lost interest and stay quiet.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "D": {
                "text": "I express my frustration directly so they know I’m upset.",
                "subtype": "LOUD DISORGANIZED"
              }
            }
          },
          {
            "block_id": "FC28",
            "prompt": "You notice your partner being secretive with or hiding their phone.",
            "options": {
              "A": {
                "text": "I trust them until I have proof otherwise.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I panic that they might be betraying me.",
                "subtype": "NURTURING ANXIOUS"
              },
              "C": {
                "text": "I stop responding until they explain themselves.",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "D": {
                "text": "I freeze, unsure what to say.",
                "subtype": "QUIET DISORGANIZED"
              }
            }
          },
          {
            "block_id": "FC29",
            "prompt": "A friend reminds you of a secret from your past.",
            "options": {
              "A": {
                "text": "I thank them for keeping it private and believe they are trustworthy.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I feel uneasy, worrying they’ll share it.",
                "subtype": "QUIET DISORGANIZED"
              },
              "C": {
                "text": "I wonder why they felt the need to tell me.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "D": {
                "text": "I feel angry and need to know that they will not expose me.",
                "subtype": "LOUD DISORGANIZED"
              }
            }
          },
          {
            "block_id": "FC30",
            "prompt": "Your partner praises your problem-solving skills (again).",
            "options": {
              "A": {
                "text": "I accept it without overthinking.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I wonder what they expect from me next.",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "C": {
                "text": "I doubt they really mean it.",
                "subtype": "QUIET DISORGANIZED"
              },
              "D": {
                "text": "I think of my past doubts and feel proud of my growth.",
                "subtype": "REMADE SECURE"
              }
            }
          },
          {
            "block_id": "FC31",
            "prompt": "Your partner asks why you didn’t call back.",
            "options": {
              "A": {
                "text": "I explain calmly and reassure them.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I worry they’ll think I’m uncaring.",
                "subtype": "TOXIC ANXIOUS"
              },
              "C": {
                "text": "I freeze inside and can’t form a reply.",
                "subtype": "QUIET DISORGANIZED"
              },
              "D": {
                "text": "I suggest they should have checked on me sooner.",
                "subtype": "MANIPULATIVE AVOIDANT"
              }
            }
          },
          {
            "block_id": "FC32",
            "prompt": "Someone interrupts your story in a group again.",
            "options": {
              "A": {
                "text": "I continue gently, trusting they’ll listen later.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I show my disappointment quietly.",
                "subtype": "QUIET DISORGANIZED"
              },
              "C": {
                "text": "I snap at them and ask if I can finish my story before they interrupt again.",
                "subtype": "LOUD DISORGANIZED"
              },
              "D": {
                "text": "I think, “I used to be timid, but now I stay calm.”",
                "subtype": "REMADE SECURE"
              }
            }
          },
          {
            "block_id": "FC33",
            "prompt": "A soft disagreement arises between you and someone you trust.",
            "options": {
              "A": {
                "text": "I stay calm and address issues directly.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I worry they’ll walk away if I’m honest.",
                "subtype": "NURTURING ANXIOUS"
              },
              "C": {
                "text": "I choose my words so they keep guessing how I feel.",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "D": {
                "text": "I remind myself why I trusted them, and try to work through the issue.",
                "subtype": "REMADE SECURE"
              }
            }
          },
          {
            "block_id": "FC34",
            "prompt": "A group project at work goes badly.",
            "options": {
              "A": {
                "text": "I am able to handle the disappointment without feeling guilty.",
                "subtype": "REMADE SECURE"
              },
              "B": {
                "text": "I feel resentful if my contributions go unnoticed.",
                "subtype": "TOXIC ANXIOUS"
              },
              "C": {
                "text": "I hold back my feelings to avoid upsetting anyone.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "D": {
                "text": "I make my frustration known so no one can ignore me.",
                "subtype": "LOUD DISORGANIZED"
              }
            }
          },
          {
            "block_id": "FC35",
            "prompt": "Someone praises your patience in a difficult moment.",
            "options": {
              "A": {
                "text": "I express appreciation and don’t overthink.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I try to fix everything if someone seems down.",
                "subtype": "NURTURING ANXIOUS"
              },
              "C": {
                "text": "I notice that this is a relatively new compliment for me?",
                "subtype": "REMADE SECURE"
              },
              "D": {
                "text": "I expect favors to be returned without being asked.",
                "subtype": "TOXIC ANXIOUS"
              }
            }
          },
          {
            "block_id": "FC36",
            "prompt": "You feel uncertain about expressing your needs.",
            "options": {
              "A": {
                "text": "I freeze inside when I feel unsure and don’t share.",
                "subtype": "QUIET DISORGANIZED"
              },
              "B": {
                "text": "I prefer to keep people guessing how I feel.",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "C": {
                "text": "I stay quiet rather than risk upsetting anyone.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "D": {
                "text": "I raise my voice so people can’t ignore my needs.",
                "subtype": "LOUD DISORGANIZED"
              }
            }
          },
          {
            "block_id": "FC37",
            "prompt": "A close friend seems distant, but you’re not sure why.",
            "options": {
              "A": {
                "text": "I ask questions calmly because I feel supported.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I drop everything to comfort them when they seem upset.",
                "subtype": "NURTURING ANXIOUS"
              },
              "C": {
                "text": "I keep my distance to avoid burdening them.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "D": {
                "text": "I wait quietly to see if they notice I’m upset.",
                "subtype": "LOUD DISORGANIZED"
              }
            }
          },
          {
            "block_id": "FC38",
            "prompt": "You catch yourself slipping back into old fears.",
            "options": {
              "A": {
                "text": "I think, “I’ve grown past those worries.”",
                "subtype": "REMADE SECURE"
              },
              "B": {
                "text": "I expect others to repay me for every kindness.",
                "subtype": "TOXIC ANXIOUS"
              },
              "C": {
                "text": "I prefer to keep people guessing about how I feel.",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "D": {
                "text": "I remain still, unsure what to say or do.",
                "subtype": "QUIET DISORGANIZED"
              }
            }
          },
          {
            "block_id": "FC39",
            "prompt": "You realize you’ve been over-comforting someone to feel needed.",
            "options": {
              "A": {
                "text": "I worry they’ll leave me unless I prove I care.",
                "subtype": "NURTURING ANXIOUS"
              },
              "B": {
                "text": "I feel resentful if my efforts go unnoticed.",
                "subtype": "TOXIC ANXIOUS"
              },
              "C": {
                "text": "I test loyalty by stepping back to see if they care.",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "D": {
                "text": "I worry about saying the wrong thing, so I say nothing.",
                "subtype": "QUIET DISORGANIZED"
              }
            }
          },
          {
            "block_id": "FC40",
            "prompt": "You suspect someone you care about is ignoring your efforts.",
            "options": {
              "A": {
                "text": "I worry they’ll leave me unless I prove I care.",
                "subtype": "NURTURING ANXIOUS"
              },
              "B": {
                "text": "I feel resentful if my efforts go unnoticed.",
                "subtype": "TOXIC ANXIOUS"
              },
              "C": {
                "text": "I stay quiet rather than risk upsetting anyone.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "D": {
                "text": "I raise my voice so that they can see my efforts.",
                "subtype": "LOUD DISORGANIZED"
              }
            }
          },
          {
            "block_id": "FC41",
            "prompt": "You’re torn between forgiving someone who hurt you or holding a grudge.",
            "options": {
              "A": {
                "text": "I consider what decision will make me respect myself.",
                "subtype": "REMADE SECURE"
              },
              "B": {
                "text": "I create distance and hold a grudge to see if they’ll care.",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "C": {
                "text": "I worry they’ll leave me if I don’t forgive them.",
                "subtype": "NURTURING ANXIOUS"
              },
              "D": {
                "text": "I hold a grudge because I need them to feel bad.",
                "subtype": "TOXIC ANXIOUS"
              }
            }
          },
          {
            "block_id": "FC42",
            "prompt": "A friend says they respect your progress but won’t say why.",
            "options": {
              "A": {
                "text": "I ask, ‘What do you mean?’ without overanalyzing.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "I express frustration because I’m the only one changing.",
                "subtype": "TOXIC ANXIOUS"
              },
              "C": {
                "text": "I feel confused but say, “thank you.”",
                "subtype": "QUIET DISORGANIZED"
              },
              "D": {
                "text": "I feel appreciative because I have made progress.",
                "subtype": "REMADE SECURE"
              }
            }
          }
        ],
        "scenario_choice": [
          {
            "block_id": "SC1",
            "prompt": "If your partner arrives late for an important dinner, you …",
            "options": {
              "A": {
                "text": "Tell myself they did what was best, because I trust they care about me.",
                "subtype": "SECURE"
              },
              "B": {
                "text": "Worry I made them upset and apologize more than necessary.",
                "subtype": "NURTURING ANXIOUS"
              },
              "C": {
                "text": "Test loyalty by pretending not to care.",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "D": {
                "text": "Freeze inside, unsure what to say.",
                "subtype": "QUIET DISORGANIZED"
              }
            }
          },
          {
            "block_id": "SC2",
            "prompt": "If someone close hurts you once but then sincerely apologizes, you …",
            "options": {
              "A": {
                "text": "Trust their apology because I know people can change.",
                "subtype": "REMADE SECURE"
              },
              "B": {
                "text": "Worry they’ll hurt me again despite the apology.",
                "subtype": "QUIET DISORGANIZED"
              },
              "C": {
                "text": "Offer a brief forgiveness but remain cautious.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "D": {
                "text": "Expect a clear gesture to prove they mean it.",
                "subtype": "TOXIC ANXIOUS"
              }
            }
          },
          {
            "block_id": "SC3",
            "prompt": "When a friend asks why you haven’t shared your true feelings, you …",
            "options": {
              "A": {
                "text": "Say, ‘I’m fine,’ hoping they won’t pry further.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "B": {
                "text": "Open up immediately so they know I trust them.",
                "subtype": "SECURE"
              },
              "C": {
                "text": "I have no idea what to say. I probably freeze and stay quiet.",
                "subtype": "QUIET DISORGANIZED"
              },
              "D": {
                "text": "Tell them I’m not in the mood to talk right now.",
                "subtype": "LOUD DISORGANIZED"
              }
            }
          },
          {
            "block_id": "SC4",
            "prompt": "If your partner spends time with someone you don’t trust, you …",
            "options": {
              "A": {
                "text": "I think of how to level the playing field.",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "B": {
                "text": "Worry they’re taking a bad path and stay vigilant in case they start to change.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "C": {
                "text": "I tell them they need to choose between that person and me.",
                "subtype": "LOUD DISORGANIZED"
              },
              "D": {
                "text": "Freeze mid-conversation, unable to say anything.",
                "subtype": "QUIET DISORGANIZED"
              }
            }
          },
          {
            "block_id": "SC5",
            "prompt": "When your partner seems upset but won’t say why, you …",
            "options": {
              "A": {
                "text": "Try everything to cheer them up, even if it exhausts me.",
                "subtype": "NURTURING ANXIOUS"
              },
              "B": {
                "text": "Back off, assuming they’d rather handle it alone.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "C": {
                "text": "Withdraw and wait for them to ask if I’m okay.",
                "subtype": "LOUD DISORGANIZED"
              },
              "D": {
                "text": "Say, ‘I’m here whenever you’re ready to talk.’",
                "subtype": "SECURE"
              }
            }
          },
          {
            "block_id": "SC6",
            "prompt": "You lend a friend money, and they forget to pay you back. You …",
            "options": {
              "A": {
                "text": "Insist they return it soon before I feel comfortable talking again.",
                "subtype": "TOXIC ANXIOUS"
              },
              "B": {
                "text": "Feel hurt but say nothing to avoid conflict.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "C": {
                "text": "Assume that they don’t care, then help them less next time.",
                "subtype": "MANIPULATIVE AVOIDANT"
              },
              "D": {
                "text": "Let it go quickly and move on—everyone makes mistakes.",
                "subtype": "SECURE"
              }
            }
          },
          {
            "block_id": "SC7",
            "prompt": "When you realize someone close lied to you, you …",
            "options": {
              "A": {
                "text": "Stay silent and feel shaken inside.",
                "subtype": "QUIET DISORGANIZED"
              },
              "B": {
                "text": "Confront them firmly so they know I caught them.",
                "subtype": "LOUD DISORGANIZED"
              },
              "C": {
                "text": "Feel disappointment but say nothing and trust them less in the future.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "D": {
                "text": "Trust it’s a misunderstanding and let it pass.",
                "subtype": "SECURE"
              }
            }
          },
          {
            "block_id": "SC8",
            "prompt": "If a friend cancels plans at the last minute, you …",
            "options": {
              "A": {
                "text": "Make my frustration clear and then create distance for some time.",
                "subtype": "LOUD DISORGANIZED"
              },
              "B": {
                "text": "Respond ‘that’s ok’ but inside feel less trust.",
                "subtype": "ETHICAL AVOIDANT"
              },
              "C": {
                "text": "Feel they owe me an explanation and hint at my disappointment.",
                "subtype": "TOXIC ANXIOUS"
              },
              "D": {
                "text": "Assume they’re busy and wait calmly to hear back.",
                "subtype": "SECURE"
              }
            }
          }
        ],
        "likert": [
          {
            "item_id": "L1",
            "text": "I feel comfortable depending on others without fear.",
            "subtype": "SECURE"
          },
          {
            "item_id": "L2",
            "text": "I am confident that my close relationships are stable.",
            "subtype": "SECURE"
          },
          {
            "item_id": "L3",
            "text": "I openly discuss my feelings without worrying about judgment.",
            "subtype": "SECURE"
          },
          {
            "item_id": "L4",
            "text": "I trust that people I care about have my best interests at heart.",
            "subtype": "SECURE"
          },
          {
            "item_id": "L5",
            "text": "When I feel upset, I know I can rely on someone to support me.",
            "subtype": "SECURE"
          },
          {
            "item_id": "L6",
            "text": "I used to struggle with trust, but now I feel secure.",
            "subtype": "REMADE SECURE"
          },
          {
            "item_id": "L7",
            "text": "Sometimes I worry old insecurities might return, but I set them aside.",
            "subtype": "REMADE SECURE"
          },
          {
            "item_id": "L8",
            "text": "I remind myself how far I’ve come whenever I feel doubtful.",
            "subtype": "REMADE SECURE"
          },
          {
            "item_id": "L9",
            "text": "I know past relationship hurts don’t define my current trust.",
            "subtype": "REMADE SECURE"
          },
          {
            "item_id": "L10",
            "text": "I feel grateful for how much I’ve grown in trusting others.",
            "subtype": "REMADE SECURE"
          },
          {
            "item_id": "L11",
            "text": "I often hold back feelings because people can’t handle it.",
            "subtype": "ETHICAL AVOIDANT"
          },
          {
            "item_id": "L12",
            "text": "I don’t need people to know what I feel.",
            "subtype": "ETHICAL AVOIDANT"
          },
          {
            "item_id": "L13",
            "text": "I usually handle things on my own because people can be unreliable.",
            "subtype": "ETHICAL AVOIDANT"
          },
          {
            "item_id": "L14",
            "text": "I think people are too emotional during conflict so I’d rather not speak up.",
            "subtype": "ETHICAL AVOIDANT"
          },
          {
            "item_id": "L15",
            "text": "I think people are untrustworthy and have too high of expectations.",
            "subtype": "ETHICAL AVOIDANT"
          },
          {
            "item_id": "L16",
            "text": "I sometimes hide my true feelings to keep control.",
            "subtype": "MANIPULATIVE AVOIDANT"
          },
          {
            "item_id": "L17",
            "text": "I might distance myself just to see if someone really cares.",
            "subtype": "MANIPULATIVE AVOIDANT"
          },
          {
            "item_id": "L18",
            "text": "I occasionally test people’s loyalty by withholding affection.",
            "subtype": "MANIPULATIVE AVOIDANT"
          },
          {
            "item_id": "L19",
            "text": "I prefer to keep others guessing about how I feel.",
            "subtype": "MANIPULATIVE AVOIDANT"
          },
          {
            "item_id": "L20",
            "text": "I guide conversations so that I can get the best outcome.",
            "subtype": "MANIPULATIVE AVOIDANT"
          },
          {
            "item_id": "L21",
            "text": "I worry that if I don’t do enough, people will leave me.",
            "subtype": "NURTURING ANXIOUS"
          },
          {
            "item_id": "L22",
            "text": "I go out of my way to comfort others because I fear losing them.",
            "subtype": "NURTURING ANXIOUS"
          },
          {
            "item_id": "L23",
            "text": "When someone seems upset, I drop everything to try to fix things.",
            "subtype": "NURTURING ANXIOUS"
          },
          {
            "item_id": "L24",
            "text": "I often feel I’m not caring enough unless I’m constantly giving.",
            "subtype": "NURTURING ANXIOUS"
          },
          {
            "item_id": "L25",
            "text": "I fret that those I love will be disappointed if I don’t show enough affection.",
            "subtype": "NURTURING ANXIOUS"
          },
          {
            "item_id": "L26",
            "text": "I expect people to return favors; otherwise, I feel resentful.",
            "subtype": "TOXIC ANXIOUS"
          },
          {
            "item_id": "L27",
            "text": "If others don’t acknowledge what I do, I feel bitter.",
            "subtype": "TOXIC ANXIOUS"
          },
          {
            "item_id": "L28",
            "text": "I hold grudges when people don’t meet my unspoken expectations.",
            "subtype": "TOXIC ANXIOUS"
          },
          {
            "item_id": "L29",
            "text": "I sometimes withdraw support if I feel unappreciated.",
            "subtype": "TOXIC ANXIOUS"
          },
          {
            "item_id": "L30",
            "text": "I believe my kindness should be repaid with equal effort.",
            "subtype": "TOXIC ANXIOUS"
          },
          {
            "item_id": "L31",
            "text": "I keep a calm face, but inside I feel anxious and confused.",
            "subtype": "QUIET DISORGANIZED"
          },
          {
            "item_id": "L32",
            "text": "I often freeze instead of responding.",
            "subtype": "QUIET DISORGANIZED"
          },
          {
            "item_id": "L33",
            "text": "I worry about saying the wrong thing, so I stay silent.",
            "subtype": "QUIET DISORGANIZED"
          },
          {
            "item_id": "L34",
            "text": "Even when people show they care, I quietly doubt their motives.",
            "subtype": "QUIET DISORGANIZED"
          },
          {
            "item_id": "L35",
            "text": "I feel uncertain about my emotions and don’t express them.",
            "subtype": "QUIET DISORGANIZED"
          },
          {
            "item_id": "L36",
            "text": "When I feel hurt, I express myself forcefully, then regret it.",
            "subtype": "LOUD DISORGANIZED"
          },
          {
            "item_id": "L37",
            "text": "My emotions can swing from calm to strong anger very quickly.",
            "subtype": "LOUD DISORGANIZED"
          },
          {
            "item_id": "L38",
            "text": "I create commotion because I fear being overlooked.",
            "subtype": "LOUD DISORGANIZED"
          },
          {
            "item_id": "L39",
            "text": "I need attention in noticeable ways; subtle cues aren’t enough.",
            "subtype": "LOUD DISORGANIZED"
          },
          {
            "item_id": "L40",
            "text": "If I sense I’m being ignored, I make sure everyone hears me.",
            "subtype": "LOUD DISORGANIZED"
          },
          {
            "item_id": "L41",
            "text": "When someone pushes me to open up, I feel wary and hold back.",
            "subtype": "ETHICAL AVOIDANT"
          },
          {
            "item_id": "L42",
            "text": "If I sense someone expects me to share feelings, I change the subject.",
            "subtype": "ETHICAL AVOIDANT"
          },
          {
            "item_id": "L43",
            "text": "I worry I’ll make someone uncomfortable if I’m entirely honest.",
            "subtype": "ETHICAL AVOIDANT"
          },
          {
            "item_id": "L44",
            "text": "Even if I’m stressed, I believe my partner still loves me unconditionally.",
            "subtype": "SECURE"
          },
          {
            "item_id": "L45",
            "text": "I feel comfortable admitting my mistakes because I trust it won’t harm us.",
            "subtype": "SECURE"
          },
          {
            "item_id": "L46",
            "text": "If I disagree with someone I care about, I calmly discuss it rather than react or hide.",
            "subtype": "SECURE"
          },
          {
            "item_id": "L47",
            "text": "I sometimes wonder if old fears will return, but I remind myself they’re in the past.",
            "subtype": "REMADE SECURE"
          },
          {
            "item_id": "L48",
            "text": "When I catch myself doubting, I recall how I overcame those doubts before.",
            "subtype": "REMADE SECURE"
          },
          {
            "item_id": "L49",
            "text": "I used to freeze in conflict, but now I speak up in a balanced way.",
            "subtype": "REMADE SECURE"
          },
          {
            "item_id": "L50",
            "text": "I expect people to notice what I do without being reminded, and feel upset if they don’t.",
            "subtype": "TOXIC ANXIOUS"
          },
          {
            "item_id": "L51",
            "text": "If someone forgets something I did for them, I keep track and remind them later.",
            "subtype": "TOXIC ANXIOUS"
          },
          {
            "item_id": "L52",
            "text": "I feel that anyone who truly cares would prioritize me when I put in effort.",
            "subtype": "TOXIC ANXIOUS"
          }
        ]
      }

    output_file = Rails.root.join('public', 'scenario_choice.docx')

    Caracal::Document.save(output_file) do |doc|
      # Document Title
      doc.h1 'Attachment Style Assessment'
      doc.p 'Generated from JSON data', align: :center, size: 12

      # Forced Choice Section
      doc.h2 'Forced Choice Questions'
      json_data[:forced_choice].each do |question|
        doc.h3 "#{question[:block_id]}: #{question[:prompt]}"
        
        question[:options].each do |key, option|
          doc.p "#{key}: #{option[:text]} (#{option[:subtype]})", indent: 400
        end
        
        doc.p '' # Add empty paragraph between questions
      end

      # Scenario Choice Section
      doc.h2 'Scenario Choice Questions'
      json_data[:scenario_choice].each do |question|
        doc.h3 "#{question[:block_id]}: #{question[:prompt]}"
        
        question[:options].each do |key, option|
          doc.p "#{key}: #{option[:text]} (#{option[:subtype]})", indent: 400
        end
        
        doc.p '' # Add empty paragraph between questions
      end

      # Likert Scale Section
      doc.h2 'Likert Scale Questions'
      doc.p 'Rate each statement on a scale from 1 (Strongly Disagree) to 5 (Strongly Agree):', size: 12
      doc.p ''
      
      json_data[:likert].each do |item|
        doc.p "#{item[:item_id]}: #{item[:text]} (#{item[:subtype]})", indent: 200
      end

      doc.p 'End of document', align: :center
    end

    puts "Word document generated at: #{output_file}"
  end
end