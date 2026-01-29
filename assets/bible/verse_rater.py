import json
import ollama
import os

# 1. SETUP PATHS
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
FILE_IN = os.path.join(BASE_DIR, 'KJV.json')
FILE_OUT = os.path.join(BASE_DIR, 'top_tier_verses.json')

with open(FILE_IN, 'r', encoding='utf-8') as f:
    bible_data = json.load(f)

# 2. INITIALIZE THE EXACT STRUCTURE
new_bible_data = {
    "translation": "KJV: King James Version (1769) with Strongs Numbers and Morphology and CatchWords",
    "books": []
}

BORING_KEYWORDS = ["begat", "cubit", "shalt", "son of", "lived after", "years and"]

print("🚀 Starting Hierarchical Filter...")

for book in bible_data['books']:
    new_book = {"name": book['name'], "chapters": []}
    
    for chapter in book['chapters']:
        new_chapter = {"chapter": chapter['chapter'], "verses": []}
        
        for verse in chapter['verses']:
            text = verse['text']
            ref = f"{book['name']} {chapter['chapter']}:{verse['verse']}"

            # STEP 1: KEYWORD AUTO-SKIP
            if any(word in text.lower() for word in BORING_KEYWORDS):
                continue

            # STEP 2: BINARY AI JUDGMENT
            prompt = f"""Is this Bible verse a famous inspirational masterpiece? 
            Answer ONLY 'YES' or 'NO'. Try to keep the verses to under 500 so be picky. If you were to rate the verses 1-10, only say 'YES' to verses that would be 10/10.  No explanations.
            Verse: "{text}" """

            try:
                response = ollama.generate(model='llama3.2', prompt=prompt, options={'temperature': 0})
                decision = response['response'].strip().upper()

                if "YES" in decision:
                    # Maintain the exact verse object format
                    new_chapter['verses'].append({
                        "verse": verse['verse'],
                        "text": text
                    })
                    print(f"✅ KEEP: {ref}")
                else:
                    # Optional: print(f"❌ SKIP: {ref}")
                    pass
            except:
                print(f"⚠️ Error at {ref}")

        # Only add the chapter if it has verses
        if new_chapter['verses']:
            new_book['chapters'].append(new_chapter)

    # Only add the book if it has chapters
    if new_book['chapters']:
        new_bible_data['books'].append(new_book)
        
        # Save progress after every book so you don't lose data
        with open(FILE_OUT, 'w', encoding='utf-8') as f_out:
            json.dump(new_bible_data, f_out, indent=4)

print(f"✨ Finished! Saved to {FILE_OUT}")