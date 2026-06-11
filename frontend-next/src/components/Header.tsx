"use client";

import React from "react";
import { Bell, HelpCircle, ChevronDown, RefreshCw } from "lucide-react";

interface HeaderProps {
  lastUpdated: string;
  onRefresh: () => void;
  isRefreshing: boolean;
}

export default function Header({ lastUpdated, onRefresh, isRefreshing }: HeaderProps) {
  return (
    <header className="bg-white border-b border-slate-200/80 px-8 py-5 flex items-start justify-between sticky top-0 z-10 shadow-sm shadow-slate-100/50">
      <div>
        <h1 className="text-2xl font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
          Good Morning, Ramesh! <span className="text-xl animate-bounce">👋</span>
        </h1>
        <p className="text-slate-500 text-sm mt-1 font-medium">
          Here's what's happening in your cold storage network today.
        </p>
      </div>

      <div className="flex flex-col items-end gap-2.5">
        <div className="flex items-center gap-5">
          {/* Action Icons */}
          <div className="flex items-center gap-3.5 text-slate-500">
            <button
              id="header-notifications-bell"
              className="relative p-2 rounded-xl hover:bg-slate-50 hover:text-slate-900 transition-all border border-transparent hover:border-slate-200"
              onClick={() => alert("Quick Alerts checklist contains 8 unresolved items.")}
            >
              <Bell className="w-5 h-5" />
              <span className="absolute -top-1 -right-1 bg-red-500 border-2 border-white text-white text-[9px] font-extrabold px-1.5 py-0.5 rounded-full">
                8
              </span>
            </button>
            <button
              id="header-faq-help"
              className="p-2 rounded-xl hover:bg-slate-50 hover:text-slate-900 transition-all border border-transparent hover:border-slate-200"
              onClick={() => alert("Opening help manual...")}
            >
              <HelpCircle className="w-5 h-5" />
            </button>
          </div>
          {/* Vertical Separator */}
          <div className="h-6 w-px bg-slate-200" />
          {/* Profile Pill */}
          <div
            id="user-profile-pill"
            className="flex items-center gap-3 cursor-pointer hover:bg-slate-50 p-1.5 pr-2.5 rounded-xl border border-transparent hover:border-slate-200 transition-all"
            onClick={() => alert("Profile details configuration panel")}
          >
            <img
              src="https://api.dicebear.com/7.x/avataaars/svg?seed=Ramesh"
              alt="Ramesh"
              className="w-8 h-8 rounded-full bg-emerald-100 border border-emerald-200"
            />
            <div className="text-left leading-tight">
              <p className="text-xs font-bold text-slate-900">Ramesh Kumar</p>
              <p className="text-[10px] text-slate-500 font-semibold uppercase tracking-wider">
                Owner
              </p>
            </div>
            <ChevronDown className="w-3.5 h-3.5 text-slate-400" />
          </div>
        </div>

        {/* Live Status Refresh */}
        <div className="flex items-center gap-2 text-[11px] text-slate-500 font-medium bg-slate-50 border border-slate-200/60 px-3 py-1 rounded-lg">
          <span className="w-1.5 h-1.5 rounded-full bg-accent animate-ping" />
          <span>Last Updated: {lastUpdated}</span>
          <button
            id="header-manual-refresh"
            onClick={onRefresh}
            className={`hover:text-slate-800 transition-colors p-0.5 rounded ${
              isRefreshing ? "animate-spin text-accent" : ""
            }`}
            title="Refresh IoT Telemetry"
          >
            <RefreshCw className="w-3 h-3" />
          </button>
        </div>
      </div>
    </header>
  );
}
