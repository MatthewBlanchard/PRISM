local util = {}

util.RE_COLORS = "()(%%([bc]){([^}]*)})"

util.TYPE_TEXT = 0
util.TYPE_NEWLINE = 1
util.TYPE_FG = 2
util.TYPE_BG = 3

function util.tokenize(str, maxWidth)
   local result = {}

   -- first tokenization pass - split texts and color formatting commands
   local offset = 1
   str:gsub(util.RE_COLORS, function(index, match, type, name)
      -- string before
      local part = str:sub(offset, index - 1)
      if #part then
         result[#result + 1] = {
            type = util.TYPE_TEXT,
            value = part
         }
      end

      -- color command
      result[#result + 1] = {
         type = type == "c" and util.TYPE_FG or util.TYPE_BG,
         value = name:gsub("^ +", ""):gsub(" +$", "")
      }

      offset = index + #match
      return ""
   end)

   -- last remaining part
   local part = str:sub(offset)
   if #part > 0 then
      result[#result + 1] = {
         type = util.TYPE_TEXT,
         value = part
      }
   end

   return (util._breakLines(result, maxWidth)) 
end

-- insert line breaks into first-pass tokenized data
function util._breakLines(tokens, maxWidth)
   maxWidth = maxWidth or math.huge

   local i = 1
   local lineLength = 0
   local lastTokenWithSpace

   -- This contraption makes `break` work like `continue`.
   -- A `break` in the `repeat` loop will continue the outer loop.
   while i <= #tokens do repeat
      -- take all text tokens, remove space, apply linebreaks
      local token = tokens[i]
      if token.type == util.TYPE_NEWLINE then -- reset
         lineLength = 0
         lastTokenWithSpace = nil
      end
      if token.type ~= util.TYPE_TEXT then -- skip non-text tokens
         i = i + 1
         break -- continue
      end

      -- remove spaces at the beginning of line
      if lineLength == 0 then
         token.value = token.value:gsub("^ +", "")
      end

      -- forced newline? insert two new tokens after this one
      local index = token.value:find("\n")
      if index then
         token.value = util._breakInsideToken(tokens, i, index, true)

         -- if there are spaces at the end, we must remove them
         -- (we do not want the line too long)
         token.value = token.value:gsub(" +$", "")
      end

      -- token degenerated?
      if token.value == "" then
         table.remove(tokens, i)
         break -- continue
      end

      if lineLength + #token.value > maxWidth then
      -- line too long, find a suitable breaking spot

         -- is it possible to break within this token?
         local index = 0
         while 1 do
               local nextIndex = token.value:find(" ", index+1)
               if not nextIndex then break end
               if lineLength + nextIndex > maxWidth then break end
               index = nextIndex
         end

         if index > 0 then -- break at space within this one
               token.value = util._breakInsideToken(tokens, i, index, true)
         elseif lastTokenWithSpace then
               -- is there a previous token where a break can occur?
               local token = tokens[lastTokenWithSpace]
               local breakIndex = token.value:find(" [^ ]-$")
               token.value = util._breakInsideToken(
                  tokens, lastTokenWithSpace, breakIndex, true)
               i = lastTokenWithSpace
         else -- force break in this token
               token.value = util._breakInsideToken(
                  tokens, i, maxWidth-lineLength+1, false)
         end

      else -- line not long, continue
         lineLength = lineLength + #token.value
         if token.value:find(" ") then lastTokenWithSpace = i end
      end

      i = i + 1 -- advance to next token
   until true end
   -- end of "continue contraption"

   -- insert fake newline to fix the last text line
   tokens[#tokens + 1] = { type = util.TYPE_NEWLINE }

   -- remove trailing space from text tokens before newlines
   local lastTextToken
   for i = 1, #tokens do
      local token = tokens[i]
      if token.type == util.TYPE_TEXT then
         lastTextToken= token
      elseif token.type == util.TYPE_NEWLINE then
         if lastutilToken then -- remove trailing space
               lastutilToken.value = lastTextToken.value:gsub(" +$", "")
         end
         lastutilToken = nil
      end
   end

   tokens[#tokens] = nil -- remove fake token

   return tokens
end

function util._breakInsideToken(tokens, tokenIndex, breakIndex, removeBreakChar)
   local newBreakToken = {
      type = util.TYPE_NEWLINE,
   }

   local newutilToken = {
      type = util.TYPE_TEXT,
      value = tokens[tokenIndex].value:sub(
         breakIndex + (removeBreakChar and 1 or 0))
   }

   table.insert(tokens, tokenIndex + 1, newutilToken)
   table.insert(tokens, tokenIndex + 1, newBreakToken)

   return tokens[tokenIndex].value:sub(1, breakIndex - 1)
end

function util.assert(pass, ...)
   if pass then
      return pass, ...
   elseif select('#', ...) > 0 then
      error(table.concat({...}), 2)
   else
      error('assertion failed!', 2)
   end
end

return util