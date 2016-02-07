#!/usr/bin/gjs

const Lang = imports.lang;
const Gtk = imports.gi.Gtk;
const GLib = imports.gi.GLib;

const TcEditor = new Lang.Class({
    Name: 'TcEditor',

    //create the application
    _init: function() {
        this.application = new Gtk.Application();

       //connect to 'activate' and 'startup' signals to handlers.
       this.application.connect('activate', Lang.bind(this, this._onActivate));
       this.application.connect('startup', Lang.bind(this, this._onStartup));
    },

    //create the UI
    _buildUI: function() {
        this._window = new Gtk.ApplicationWindow({ application: this.application,
                                                   title: "Network emulator" });
        this._window.set_default_size(200, 200);
        this._grid = new Gtk.Grid({ margin_left: 10, margin_top: 10, margin_right: 10, margin_bottom: 10, column_spacing: 10, row_spacing: 10 });
        this._window.add(this._grid);

        this._grid.attach(new Gtk.Label({ label: "delay" }), 0, 0, 1, 1);
        this._grid.attach(new Gtk.Label({ label: "rate" }), 0, 1, 1, 1);
        this._grid.attach(new Gtk.Label({ label: "loss" }), 0, 2, 1, 1);

        this.entryDelay = new Gtk.Entry({ text: "10ms" });
        this.entryRate = new Gtk.Entry({ text: "8192kbit" });
        this.entryLoss = new Gtk.Entry({ text: "0.001%" });
        this._grid.attach(this.entryDelay, 1, 0, 1, 1);
        this._grid.attach(this.entryRate, 1, 1, 1, 1);
        this._grid.attach(this.entryLoss, 1, 2, 1, 1);

        this._button = Gtk.Button.new_with_label("Apply");
	this._button.connect('clicked', Lang.bind(this, this._onApply))
        this._grid.attach(this._button, 1, 3, 1, 1);
    },

    //handler for 'activate' signal
    _onActivate: function() {
        //show the window and all child widgets
        this._window.show_all();
    },

    //handler for 'startup' signal
    _onStartup: function() {
        this._buildUI();
    },

    //handler for the button 'clicked' signal
    _onApply: function() {
        let cmd = "tc qdisc change dev eth0 root handle 1: netem delay " + 
                this.entryDelay.text + " loss " + this.entryLoss.text + " rate " + this.entryRate.text;
        GLib.spawn_command_line_sync(cmd, null, null, null, null)
    }
});

//run the application
let app = new TcEditor();
app.application.run(ARGV);
