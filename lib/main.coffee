{CompositeDisposable, Point} = require 'atom'

settings = require(atom.packages.resolvePackagePath('narrow') + '/lib/settings')

module.exports =
  config: settings.createProviderConfig({})

  activate: ->
    @consumeNarrowServicePromise = new Promise (resolve) =>
      @resolveNarrowService = resolve

    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-text-editor',
      'narrow:example-provider': => @narrow('example-provider')

  deactivate: ->
    @subscriptions.dispose()

  narrow: (args...) ->
    if @service?
      @service.narrow(args...)
    else
      editor = atom.workspace.getActiveTextEditor()
      atom.commands.dispatch(editor.element, 'narrow:activate-package')
      @consumeNarrowServicePromise.then (@service) =>
        @registerProvider(@service)
        @service.narrow(args...)

  registerProvider: (service) ->
    class ExampleProvider extends service.ProviderBase
      @configScope: 'narrow-example-provider'
      boundToSingleFile: true

      getItems: ->
        items = [
          {point: new Point(0, 0), text: @editor.lineTextForBufferRow(0)}
          {point: new Point(1, 0), text: @editor.lineTextForBufferRow(1)}
          {point: new Point(2, 0), text: @editor.lineTextForBufferRow(2)}
          {point: new Point(3, 0), text: @editor.lineTextForBufferRow(3)}
          {point: new Point(4, 0), text: @editor.lineTextForBufferRow(4)}
        ]
        @finishUpdateItems(items)
    service.registerProvider('example-provider', ExampleProvider)

  consumeNarrow: (service) ->
    @resolveNarrowService(service)
