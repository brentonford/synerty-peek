.. _setup_pycharm_ide:

=================
Setup Pycharm IDE
=================

#.  Open pycharm,

    #.  Open the peek project, open in new window
    #.  Open each of the other projects mentioned above, add to current window

#.  File -> Settings (Ctrl+Alt+S with eclipse keymap)

    #. Editor -> Inspection (use the search bar for finding the inspections)

        #.  Disable Python -> "PEP8 Naming Convention Violation"
        #.  Change Python -> "Type Checker" from warning to error
        #.  Change Python -> "Incorrect Docstring" from warning to error
        #.  Change Python -> "Missing type hinting ..." from warning to error
        #.  Change Python -> "Incorrect call arguments" from warning to error
        #.  Change Python -> "Unresolved references" from warning to error

    #. Project -> Project Dependencies

        #.  peek_platform depends on -> plugin_base
        #.  peek_server depends on -> peek_platform, peek_admin
        #.  peek_client depends on -> peek_platform, peek_mobile
        #.  peek_agent depends on -> peek_platform
        #.  peek_worker depends on -> peek_platform

    #.  Project -> Project Structure

        #.  peek-mobile -> build-ns -> Excluded (as per the image below)
        #.  peek-desktop -> build-web -> Excluded
        #.  peek-admin -> build-web -> Excluded

        .. image:: PyCharmSettingsProjectStructureExclude.jpg

    #.  Languages & Frameworks -> Node.js and NPM

        #.  Node interpreter -> ~/node-v7.1.0/bin/node
        #.  Remove other node interpreters

        .. image:: settings_nodejs_and_npm.png

    #.  Languages & Frameworks -> TypesScript

        #.  Node interpreter -> ~/node-v7.1.0/bin/node
        #.  Enable TypeScript Compiler -> Checked
        #.  Set options manually -> Checked
        #.  Command line options -> --target es5 --experimentalDecorators --lib es6,dom --sourcemap --emitDecoratorMetadata
        #.  Generate source maps -> Checked

        .. image:: settings_typescript.png

    #.  Languages & Frameworks -> Typescript -> TSLint

        #.  Select "Enable"
        #.  Node interpreter -> ~/node-v7.1.0/bin/node
        #.  TSLint Package -> ~/node-v7.1.0/lib/node_modules/tslint

        .. image:: settings_tslint.png

Configure your developing software to use the virtual environment you wish to use

Here is an example of the setting in PyCharm:

.. image:: PycharmProjectInterpreter.jpg

----

Restart the services that use the plugin

.. NOTE:: The plugins that aren't being developed should be installed as per
    :ref:`deploy_peek_plugins`

----

This is an example of running the server service in debug mode using **PyCharm**

Under the drop down "Run" then "Edit Configurations..."

1.  Add new configuration, select "Python"
2.  Update the "Name:"
3.  Locate the script you wish to run
4.  Check that the "Python Interpreter" is correct

.. image:: PycharmDebugRunServer.jpg
