---
title: "Polish any text with AI from anywhere on Linux"
header:
  image: /assets/images/headers/2024-10-25_polish-text-with-ai.jpg
  image_description: "A Linux terminal showing the Polish script in action"
  teaser: /assets/images/teasers/2024-10-25_polish-text-with-ai.jpg
excerpt: A simple bash script that lets you polish text with any AI service from any application without installing browser extensions or heavy desktop apps.
---

We spend countless hours writing in web applications - drafting emails in Gmail, collaborating on documents in Google Docs, messaging in Slack.
When we want AI assistance with our writing, we're stuck with an awkward dance: copy text, switch to an AI tool, paste, wait, copy the result, switch back, and paste again.

Browser extensions promise to solve this, but they come with a catch.
The good ones cost money, and the free ones often require handing over your precious API keys to unknown developers.
Not exactly reassuring when you're dealing with sensitive work content.

What if we flipped the script?
Instead of fighting the copy-paste workflow, let's automate it completely using tools we control.

Here's how to build a lightweight system that polishes any text with AI from anywhere on your Linux machine - no browser extensions, no questionable permissions, just standard command-line tools working together.

*Note: This guide uses Linux command-line tools. Windows and macOS users will have to figure out their own equivalent solutions - or you know, just switch to Linux already. Your productivity is clearly suffering without proper command-line tools anyway.*

# Automate copy pasting with xdotool

`xdotool` is ideal to automate the one piece that is a pain to do manually: Copy-pasting!
It can handle Ctrl+c and Ctrl+v for us.

```bash
# Get the text to polish from the current selection
xdotool key ctrl+c
sleep 0.1  # Small delay to ensure copy completes
```

This simple command sequence copies whatever text you have selected in any application.
The small delay ensures the copy operation completes before we try to read the clipboard.

# Reading clipboard content with xclip

Once we've copied the text, we need to read it from the clipboard.
That's where `xclip` comes in:

```bash
# Use xclip to read clipboard content
clipboard_content=$(xclip -selection clipboard -o 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$clipboard_content" ]; then
    echo "Error: Could not read clipboard or clipboard is empty"
    exit 1
fi
```

The `-selection clipboard` flag ensures we're reading from the standard clipboard (not the primary selection), and `-o` outputs the content.
We also add some error handling to make sure we actually got something.

# Crafting the perfect prompt

Before we dive into the API magic, let's talk about the `STATIC_PROMPT` variable that makes this whole thing work.
This is where you define exactly what you want the AI to do with your text:

```bash
STATIC_PROMPT="You are an expert business writer specialized in drafting and refining professional documents for a software development consulting company.
Polish the following text by improving grammar, word choice, and sentence structure without making it longer or adding content.
Return only the polished text with no introduction, explanation, or commentary.
Use \"-\" for bullet points to make copy-pasting to my text editor and browser simpler.
Preserve the indentation of the bullet points.

My text:
"
```

The key is being specific about what you want:
- **Be clear about the task**: "Polish the text" is vague, "improve grammar, word choice, and sentence structure" is actionable
- **Set boundaries**: "without making it longer" prevents the AI from going overboard
- **Specify the output format**: "Return only the polished text" avoids unwanted commentary
- **Handle formatting quirks**: The bullet point instruction works around clipboard limitations we discussed earlier

Feel free to customize this for your needs - maybe you want more casual language, or you're working on technical documentation, or you need different formatting rules.

# Talking to your AI service with curl and jq

Now for the API magic.
We combine our static prompt with the clipboard content and send it to your AI service of choice.

*I'm using Claude 3.5 Sonnet as an example here, but this approach works with any LLM that provides an HTTP API - OpenAI's GPT models, Anthropic's Claude family, Google's Gemini, or even local services like Ollama.*

```bash
# Prepare the API request to Claude 3.5
full_prompt="$STATIC_PROMPT$clipboard_content"

# Create properly formatted JSON payload
json_payload=$(mktemp)
cat > "$json_payload" << EOF
{
  "model": "claude-3-5-sonnet-20240620",
  "max_tokens": 1024,
  "messages": [
    {
      "role": "user",
      "content": $(printf '%s' "$full_prompt" | jq -Rs .)
    }
  ]
}
EOF

response=$(curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d @"$json_payload")

rm "$json_payload"
```

The key trick here is using `jq -Rs .` to properly escape the text for JSON.
This handles any special characters or newlines in your selected text.

# Putting it all back

Finally, we extract Claude's response and paste it back:

```bash
# Extract Claude's response
claude_response=$(echo "$response" | jq -r '.content[0].text' 2>/dev/null)
processed_response=$(echo -e "$claude_response")

# Copy to clipboard and paste automatically
echo -e "$processed_response" | xclip -selection clipboard
xdotool key ctrl+v
```

And that's it!
Your selected text is now polished and pasted back automatically.

# Setting up the hotkey

Here's the crucial part that makes this whole system seamless: you can't just run the script from a terminal.
If you do, the terminal window will steal focus, and when `xdotool` tries to copy your selection, it'll be copying from the terminal instead of your original application.

You need to trigger the script while keeping focus on your text editor, browser, or whatever app you're writing in.
Here are the best approaches:

## Desktop environment hotkey

Most desktop environments let you bind custom scripts to keyboard shortcuts:

**GNOME (Ubuntu, Fedora):**
- Go to Settings → Keyboard → Keyboard Shortcuts
- Add a custom shortcut pointing to your script
- I use `Super+P` (Windows key + P)

**KDE Plasma:**
- System Settings → Shortcuts → Custom Shortcuts
- Create a new global shortcut for your script

**i3/sway:**
Add to your config file:
```
bindsym $mod+p exec /path/to/your/polish-script
```

## Application launcher method

If you prefer not to use a dedicated hotkey, you can trigger it through your application launcher:

**dmenu/rofi users:**
The script will show up in your launcher if it's in your PATH, and it'll run without stealing focus.

**GNOME/KDE launcher:**
Press `Super`, type "polish", hit enter - your selection stays intact while the script runs.

The key insight is that these methods run the script in the background without changing window focus, so `xdotool key ctrl+c` copies from whatever window you were actually working in.

# The complete workflow

The beauty of this approach is its simplicity:
1. Select any text in any application
2. Press your hotkey (I use Super+P)
3. Wait a moment while Claude processes it
4. The improved text replaces your selection

No browser extensions, no complex installations, just standard Linux tools working together.

*The complete Polish script is available as a [GitHub Gist](https://gist.github.com/hillairet/polish-script) if you'd like to try this yourself. Feel free to adapt it for your own use cases!*

# Caveats with rich text applications

While this approach works great with most applications, there's one gotcha to watch out for: apps that use rich text formatting.

Take Slack, for example.
When you select text that includes bullet points or other formatting in Slack, the clipboard only gets the plain text version - no bullet points, no formatting.
So even if Claude adds bullet points to improve your text, when you paste it back into Slack, those bullet points won't render properly and your message will look wonky.

The same issue can happen with other rich text editors like Google Docs, Notion, or any WYSIWYG editor that strips formatting when copying to the system clipboard.

For these apps, you'll want to:
- Stick to plain text improvements (grammar, word choice, sentence structure)
- Avoid asking for formatting changes like bullet points or bold text
- Or use the script in plain text editors first, then copy the result manually

It's not a dealbreaker, just something to keep in mind depending on where you're writing.

# Beyond text polishing

This is just one example of what you can build with basic Linux tools and APIs.
The same pattern works for:

- Translation services
- Code formatting and explanation
- Summarization
- Grammar checking
- Style conversion (formal to casual, etc.)

You could even use a local model like Gemma 270M for complete privacy and control - no API keys, no internet required, just pure local processing.

The real power lies in combining simple, reliable tools you control into workflows that solve your specific problems.
What will you automate next?

---
