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
    if (line.includes('run_board_page.dart')) {
      try {
        const data = JSON.parse(line);
        if (data.tool_responses) {
          for (const resp of data.tool_responses) {
            if (resp.output && resp.output.includes('run_board_page.dart') && resp.output.includes('Total Lines: 1017')) {
              if (resp.output.length > maxLength) {
                maxLength = resp.output.length;
                bestContent = resp.output;
              }
            }
          }
        }
      } catch (e) { }
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
