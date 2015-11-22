{BufferedProcess, Notification} = require 'atom'

commands =
  'follow': 'FollowLocation'
contextMenu = null

# Returns filepath, contents, filetypes, bufferPosition; we're not yet using
# everything.
#
# Stolen from you-complete-me.
getEditorData = (editor = atom.workspace.getActiveTextEditor(),
                 scopeDescriptor = editor.getRootScopeDescriptor()) ->
  filepath = editor.getPath()
  contents = editor.getText()
  filetypes =
    scopeDescriptor.getScopesArray().map (scope) -> scope.split('.').pop()
  bufferPosition = editor.getCursorBufferPosition()
  if filepath?
    return Promise.resolve {filepath, contents, filetypes, bufferPosition}
  else
    return new Promise (fulfill, reject) ->
      filepath = path.resolve os.tmpdir(), "AtomicRtagsBuffer-#{editor.id}"
      file = new File filepath
      file.write contents
        .then -> fulfill {filepath, contents, filetypes, bufferPosition}
        .catch (error) -> reject error

# Called immediately after follow-location opens the right file at the right
# location. After that, it's a matter of re-centering the screen to show the
# user where she is.
#
# Stolen from atomic-emacs.
recenterTopBottom = ->
  editor = atom.workspace.getActiveTextEditor()
  return unless editor
  editorElement = atom.views.getView(editor)
  minRow = Math.min((c.getBufferRow() for c in editor.getCursors())...)
  maxRow = Math.max((c.getBufferRow() for c in editor.getCursors())...)
  minOffset = editorElement.pixelPositionForBufferPosition([minRow, 0])
  maxOffset = editorElement.pixelPositionForBufferPosition([maxRow, 0])
  editor.setScrollTop((minOffset.top + maxOffset.top - editor.getHeight())/2)

# Handle non-zero exit from rc. Unless the user has explicitly forbidden it,
# tries to start rdm automatically.
handleNonzeroExit = (rcOutput, rcError) ->
  rdmOutput = ""
  parameters =
    command: atom.config.get 'atomic-rtags.rdmExecutable'
    args: []
    stdout: (output) ->
      rdmOutput = output
    exit: (status) ->
      if status == 1
        atom.notifications.addError "rdm died on us: #{rdmOutput}"
  if rcError != ""
    atom.notifications.addError "Internal error: #{rcError}"
  else if rcOutput == ""
    atom.notifications.addInfo "Not found or Indexing in progress"
  else
    atom.notifications.addError rcOutput
    if rcOutput.indexOf("Can't seem to connect to server") > -1
      if atom.config.get 'atomic-rtags.rdmAutoSpawn'
        # Try to run rdm ourselves
        new BufferedProcess parameters
        atom.notifications.addInfo "rdm started"
      else
        atom.notifications.addInfo "Please run rdm to continue"


# The main worker that runs the specified command (currently, there's only
# FollowLocation) as a BufferedProcess, and even spawns an addition
runCommand = (command) ->
  Promise.resolve()
    .then getEditorData
    .then ({filepath, contents, filetypes, bufferPosition}) ->
      stdoutOutput = ""
      stderrOutput = ""
      parameters =
        # rc -f Module.cpp:143:7 outputs stdoutOutput with status 0 if the
        # lookup was succesful.
        command: atom.config.get 'atomic-rtags.rcExecutable'
        args: [
          "--current-file=#{filepath}"
          "--absolute-path"
          "-f"
          "#{filepath}:#{bufferPosition.row + 1}:#{bufferPosition.column + 1}"
        ]
        options: {}
        stdout: (output) ->
          stdoutOutput = output
        stderr: (output) ->
          stdErrOutput = output
        exit: (status) ->
          if status == 1
            handleNonzeroExit stdoutOutput, stderrOutput
          else if command == "FollowLocation"
            # stdoutOutput is "Module.h:217:9:   class Module : public Value {";
            # split to get the first three components, and throw away the rest.
            [newPath, row, column, _] = stdoutOutput.split ':'
            atom.workspace.open(newPath, \
            initialLine: row - 1, initialColumn: column - 1)
            recenterTopBottom
      process = new BufferedProcess parameters

# Iterate over the commands mapping at the top of this file, and register
# commands and contextMenu.
register = ->
  generatedCommands = {}
  generatedMenus = []
  for key, command of commands
    generatedCommands["atomic-rtags:#{key}"] =
      ((command) -> (event) -> runCommand command)(command)
    generatedMenus.push command: "atomic-rtags:#{key}", label: command
  atom.commands.add 'atom-text-editor', generatedCommands
  # Right-click, Rtags -> Follow Location is another way to access this.
  contextMenu = atom.contextMenu.add
    'atom-text-editor': [label: 'Rtags', submenu: generatedMenus]

deregister = ->
  contextMenu?.dispose()

module.exports =
  register: register
  deregister: deregister
