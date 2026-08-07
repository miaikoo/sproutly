const fs = require('fs');
const readline = require('readline');

async function extract() {
  const fileStream = fs.createReadStream('C:\\Users\\Mia\\.gemini\\antigravity-ide\\brain\\6cf9f109-e061-4515-ad12-ac569f82c5bc\\.system_generated\\logs\\transcript_full.jsonl');

  const rl = readline.createInterface({
    input: fileStream,
    crlfDelay: Infinity
  });

  let bestContent = '';
  let maxLength = 0;

  for await (const line of rl) {
    if (line.includes('class RunBoardPage extends ConsumerStatefulWidget')) {
      try {
        const data = JSON.parse(line);
        // It could be in tool_responses
        if (data.tool_responses) {
          for (const resp of data.tool_responses) {
            if (resp.output && resp.output.includes('class RunBoardPage extends ConsumerStatefulWidget')) {
              if (resp.output.length > maxLength) {
                maxLength = resp.output.length;
                bestContent = resp.output;
              }
            }
          }
        }
      } catch (e) {
        // ignore JSON parse error
      }
    }
  }

  if (bestContent) {
    fs.writeFileSync('d:\\Projects\\2026 Gemastik\\sprout_ly_app\\extracted_file.txt', bestContent);
    console.log('Extracted file, length: ' + maxLength);
  } else {
    console.log('Not found');
  }
}

extract();
