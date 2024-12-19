local vscode = {}
local m = {}
setmetatable(vscode, {__index = m})

m.version = vim.version()

---@class vscode.TextLine
---@field lineNumber number
---@field text string
---@field range vscode.Range
---@field rangeIncludingLineBreak vscode.Range
---@field firstNonWhitespaceCharacterIndex number
---@field isEmptyOrWhitespace boolean
m.TextLine = {}
local TextLineMeta = {}
setmetatable(m. TextLine,{__index=TextLineMeta})

---@class vscode.Command
---@field title string
---@field command string
---@field tooltip? string
---@field arguments? any[]
m.Command = {}
m.Command.__index = m.Command

---@class vscode.TextDocument
---@field uri vscode.Uri
---@field fileName string
---@field isUntitled boolean
---@field languageId string
---@field version number
---@field isDirty boolean
---@field isClosed boolean
---@field save fun():Promise<boolean>
---@field eol vscode.EndOfLine
---@field lineCount number
---@field lineAt fun(line:number):vscode.TextLine|fun(position:vscode.Position):vscode.TextLine
---@field offsetAt fun(position:vscode.Position):number
---@field positionAt fun(offset:number):vscode.Position
---@field getText fun(range?:vscode.Range):string
---@field getWordRangeAtPosition fun(position:vscode.Position, regex?:RegExp):vscode.Range?
---@field validateRange fun(range:vscode.Range):vscode.Range
---@field validatePosition fun(position:vscode.Position):vscode.Position
m.TextDocument = {}
local TextDocumentMeta = {}
setmetatable(m. TextDocument,{__index=TextDocumentMeta})

---@class vscode.Position
---@field line number
---@field character number
---@field isBefore fun(other:vscode.Position):boolean
---@field isBeforeOrEqual fun(other:vscode.Position):boolean
---@field isAfter fun(other:vscode.Position):boolean
---@field isAfterOrEqual fun(other:vscode.Position):boolean
---@field isEqual fun(other:vscode.Position):boolean
---@field compareTo fun(other:vscode.Position):number
---@field translate fun(lineDelta?:number, characterDelta?:number):vscode.Position
---@field with fun(line?:number, character?:number):vscode.Position
m.Position = {}
local PositionMeta = {}
PositionMeta.__index = PositionMeta

---@param line number
---@param character number
function m.Position.new(line, character)
  ---@type vscode.Position
  return setmetatable({},{__index=PositionMeta.new(line, character),__metatable= m.Position})
end

function PositionMeta.new(line, character)
return setmetatable({line = line, character = character}, PositionMeta)
end

---@class vscode.Range
---@field start vscode.Position
---@field end vscode.Position
---@field isEmpty boolean
---@field isSingleLine boolean
---@field contains fun(positionOrRange:vscode.Position|vscode.Range):boolean
---@field isEqual fun(other:vscode.Range):boolean
---@field intersection fun(other:vscode.Range):vscode.Range?
---@field union fun(other:vscode.Range):vscode.Range
---@field with fun(start?:vscode.Position, end?:vscode.Position):vscode.Range
m.Range = {}
local RangeMeta = {}

---@param start number
---@param end_ number
function m.Range.new(start, end_)
  ---@type vscode.Range
  return setmetatable({},{__index=RangeMeta.new(start, end_),__metatable= m.Range})
end

function RangeMeta.new(start, end_)
  return setmetatable({start = start, end_ = end_}, RangeMeta)
end

function RangeMeta:__index(key)
  if key == 'start' or key == 'end' then
    return self[key]
    elseif key =='isEmpty' then
    elseif key =='isSingleLine' then
  end
end

---@class vscode.Selection:vscode.Range
---@field anchor vscode.Position
---@field active vscode.Position
---@field isReversed boolean
m.Selection = {}
local SelectionMeta = {}
SelectionMeta.__index = SelectionMeta

---@param anchor vscode.Position
---@param active vscode.Position
function m.Selection.new(anchor, active)
  ---@type vscode.Selection
  return setmetatable({},{__index=SelectionMeta.new(anchor, active),__metatable= m.Selection})
end

function SelectionMeta.new(anchor, active)
  local self= setmetatable({anchor = anchor, active = active}, SelectionMeta)
  self.isReversed = self.anchor.isAfter(self.active)
  return self
end

---@enum vscode.TextEditorSelectionChangeKind
m.TextEditorSelectionChangeKind = {
  Keyboard = 1,
  Mouse = 2,
  Command = 3,
}

---@class vscode.TextEdit

---@class vscode.Uri
