"use client";

import React, { useState } from "react";
import {
  Snowflake,
  LayoutDashboard,
  Database,
  Box,
  Bell,
  BarChart2,
  Wrench,
  Settings,
  HelpCircle,
  ChevronLeft,
  ChevronRight,
  ChevronDown,
  Headset,
  Plus,
} from "lucide-react";

interface SidebarProps {
  activeTab: string;
  setActiveTab: (tab: string) => void;
  collapsed: boolean;
  setCollapsed: (collapsed: boolean) => void;
  onAddGoodsClick: () => void;
  appMode: "Simple" | "Advanced";
  setAppMode: (mode: "Simple" | "Advanced") => void;
}

export default function Sidebar({
  activeTab,
  setActiveTab,
  collapsed,
  setCollapsed,
  onAddGoodsClick,
  appMode,
  setAppMode,
}: SidebarProps) {
  const [showModeDropdown, setShowModeDropdown] = useState(false);

  const navItems = [
    { name: "Dashboard", icon: LayoutDashboard },
    { name: "My Storages", icon: Database },
    { name: "Inventory", icon: Box },
    { name: "Alerts", icon: Bell, badge: 8 },
    { name: "Reports", icon: BarChart2 },
    { name: "Technician", icon: Wrench },
    { name: "Settings", icon: Settings },
    { name: "FAQ", icon: HelpCircle },
  ];

  return (
    <div
      id="sidebar-container"
      className={`bg-sidebar text-slate-300 flex flex-col transition-all duration-300 flex-shrink-0 relative border-r border-slate-800 ${
        collapsed ? "w-20" : "w-64"
      }`}
    >
      {/* Brand Header */}
      <div className="p-6 flex items-center justify-between border-b border-slate-800/40">
        <div className="flex items-center gap-3 overflow-hidden">
          <div className="bg-accent/10 p-2 rounded-xl border border-accent/20">
            <Snowflake className="text-accent w-6 h-6 animate-pulse" />
          </div>
          {!collapsed && (
            <span className="text-white text-xl font-bold tracking-wide transition-opacity duration-300">
              ColdSmart
            </span>
          )}
        </div>
      </div>

      {/* Navigation List */}
      <nav className="flex-1 px-3 space-y-1.5 mt-6">
        {navItems.map((item) => {
          const isActive = activeTab === item.name;
          const Icon = item.icon;
          return (
            <button
              id={`nav-item-${item.name.toLowerCase().replace(" ", "-")}`}
              key={item.name}
              onClick={() => setActiveTab(item.name)}
              className={`w-full flex items-center justify-between px-3.5 py-3 rounded-xl transition-all duration-200 group ${
                isActive
                  ? "bg-accent text-white shadow-md shadow-accent/10 font-semibold"
                  : "hover:bg-slate-800/50 hover:text-white"
              }`}
              title={collapsed ? item.name : undefined}
            >
              <div className="flex items-center gap-3">
                <Icon
                  className={`w-5 h-5 flex-shrink-0 ${
                    isActive ? "text-white" : "text-slate-400 group-hover:text-white"
                  }`}
                />
                {!collapsed && (
                  <span className="text-sm tracking-wide">{item.name}</span>
                )}
              </div>
              {!collapsed && item.badge && (
                <span className="bg-red-500 text-white text-[10px] font-bold px-2 py-0.5 rounded-full ring-2 ring-sidebar">
                  {item.badge}
                </span>
              )}
            </button>
          );
        })}
      </nav>

      {/* Footer Area */}
      <div className="p-4 space-y-4 border-t border-slate-800/40 bg-slate-950/20">
        {/* Quick Add Goods Action */}
        <button
          id="sidebar-add-goods"
          onClick={onAddGoodsClick}
          className={`w-full bg-accent hover:bg-emerald-600 text-white flex items-center justify-center gap-2 rounded-xl font-bold transition-all shadow-md shadow-accent/10 ${
            collapsed ? "py-3" : "py-3 px-4"
          }`}
          title={collapsed ? "Add Goods" : undefined}
        >
          <Plus className="w-5 h-5 flex-shrink-0" />
          {!collapsed && <span className="text-sm">Add Goods</span>}
        </button>

        {/* App Mode Dropdown Selector */}
        {!collapsed ? (
          <div className="relative">
            <button
              id="sidebar-app-mode-toggle"
              onClick={() => setShowModeDropdown(!showModeDropdown)}
              className="w-full bg-slate-800/40 rounded-xl p-3 border border-slate-700/30 flex items-center justify-between cursor-pointer hover:bg-slate-800/70 hover:border-slate-700/60 transition-all"
            >
              <div className="flex items-center gap-2.5">
                <div className="bg-accent/20 p-1.5 rounded-lg">
                  <Snowflake className="w-4 h-4 text-accent" />
                </div>
                <div className="text-left">
                  <p className="text-[10px] text-slate-400 font-semibold tracking-wider uppercase">
                    App Mode
                  </p>
                  <p className="text-white font-bold text-xs">{appMode}</p>
                </div>
              </div>
              <ChevronDown className="w-3.5 h-3.5 text-slate-400" />
            </button>

            {showModeDropdown && (
              <div
                id="app-mode-dropdown-options"
                className="absolute bottom-full left-0 right-0 mb-2 bg-slate-800 border border-slate-700 rounded-xl shadow-xl z-50 overflow-hidden"
              >
                {(["Simple", "Advanced"] as const).map((mode) => (
                  <button
                    key={mode}
                    onClick={() => {
                      setAppMode(mode);
                      setShowModeDropdown(false);
                    }}
                    className={`w-full text-left px-4 py-2.5 text-xs font-semibold transition-colors ${
                      appMode === mode
                        ? "bg-accent text-white"
                        : "text-slate-300 hover:bg-slate-700/60 hover:text-white"
                    }`}
                  >
                    {mode} Mode
                  </button>
                ))}
              </div>
            )}
          </div>
        ) : (
          <div className="flex justify-center">
            <button
              onClick={() => setAppMode(appMode === "Simple" ? "Advanced" : "Simple")}
              className="bg-slate-800/40 p-2 rounded-xl border border-slate-700/30 text-accent hover:bg-slate-800"
              title={`Switch App Mode (Current: ${appMode})`}
            >
              <Snowflake className="w-4 h-4" />
            </button>
          </div>
        )}

        {/* Technician/Support Assistance Card */}
        {!collapsed && (
          <div className="bg-slate-900/60 border border-slate-800/80 rounded-2xl p-4 shadow-inner">
            <p className="text-xs font-bold text-white mb-0.5">Need Help?</p>
            <p className="text-[10px] text-slate-400 mb-3 leading-relaxed">
              Talk to our duty technician.
            </p>
            <div className="flex items-center justify-between">
              <button
                id="support-contact-btn"
                onClick={() => alert("Connecting to ColdSmart support desk...")}
                className="text-[10px] bg-accent/20 hover:bg-accent text-accent hover:text-white px-3.5 py-1.5 rounded-lg font-bold transition-all border border-accent/30"
              >
                Contact Now
              </button>
              <Headset className="w-4 h-4 text-slate-500" />
            </div>
          </div>
        )}

        {/* Version Tracker and Collapsing Chevron */}
        <div className="flex items-center justify-between text-[10px] text-slate-500 pt-2 px-1">
          {!collapsed && <span>ColdSmart v1.1.0</span>}
          <button
            id="sidebar-collapse-toggle"
            onClick={() => setCollapsed(!collapsed)}
            className="hover:text-slate-300 p-1.5 rounded-lg hover:bg-slate-800/40 transition-colors ml-auto"
            title={collapsed ? "Expand sidebar" : "Collapse sidebar"}
          >
            {collapsed ? (
              <ChevronRight className="w-4 h-4" />
            ) : (
              <ChevronLeft className="w-4 h-4" />
            )}
          </button>
        </div>
      </div>
    </div>
  );
}
