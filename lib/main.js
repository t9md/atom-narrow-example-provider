const {CompositeDisposable, Point} = require("atom")

const settings = require(atom.packages.resolvePackagePath("narrow") +
  "/lib/settings")

module.exports = {
  config: settings.createProviderConfig({}),

  activate() {
    this.subscriptions = new CompositeDisposable()

    this.subscriptions.add(
      atom.commands.add("atom-text-editor", {
        "narrow:example-provider": () => this.narrow("example-provider"),
      })
    )
  },

  deactivate() {
    return this.subscriptions.dispose()
  },

  narrow(...args) {
    if (!this.service) {
      // kick consumeService
      const editor = atom.workspace.getActiveTextEditor()
      atom.commands.dispatch(editor.element, "narrow:activate-package")
    }
    this.service.narrow(...args)
  },

  getClass() {
    class ExampleProvider extends service.ProviderBase {
      constructor(...args) {
        super(...args)
        this.boundToSingleFile = true
      }

      getItems() {
        const items = [
          {point: new Point(0, 0), text: this.editor.lineTextForBufferRow(0)},
          {point: new Point(1, 0), text: this.editor.lineTextForBufferRow(1)},
          {point: new Point(2, 0), text: this.editor.lineTextForBufferRow(2)},
          {point: new Point(3, 0), text: this.editor.lineTextForBufferRow(3)},
          {point: new Point(4, 0), text: this.editor.lineTextForBufferRow(4)},
        ]
        this.finishUpdateItems(items)
      }
    }
    ExampleProvider.configScope = "narrow-example-provider"
    return ExampleProvider
  },

  consumeNarrow(service) {
    service.registerProvider("example-provider", getClass())
    this.service = service
  },
}
