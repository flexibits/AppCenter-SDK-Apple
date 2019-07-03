// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

import Cocoa

class EventFilterViewController: NSViewController {

  var appCenter: AppCenterDelegate = AppCenterProvider.shared().appCenter!

  @IBOutlet weak var setEnabledButton: NSButton!

  @IBAction func setEnabled(_ sender: NSButton) {
    appCenter.setEventFilterEnabled(sender.state == 1)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    appCenter.startEventFilterService()
    setEnabledButton?.state = appCenter.isEventFilterEnabled() ? 1 : 0
  }
}
