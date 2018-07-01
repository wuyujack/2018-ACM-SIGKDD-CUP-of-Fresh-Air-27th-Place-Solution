# -*- coding: utf-8 -*-
"""
Created on Mon May 28 08:53:24 2018

@author: JasonLeung
"""

import urllib
import json
import pandas as pd
html = urllib.request.urlopen('https://biendata.com/competition/kdd_2018_leaderboard_data/')
hjson = json.loads(html.read())
zdf = pd.DataFrame(hjson[1:])
columns = hjson[0]['date'].copy()
columns.append('team_name')
jsdf = zdf[columns]
jsdf.loc[:,hjson[0]['date']] = jsdf.loc[:,hjson[0]['date']].applymap(lambda x:round(float(x),5))
jsdf['zzdf'] = jsdf.apply( lambda x :x[hjson[0]['date']].sort_values().head(len(hjson[0]['date']) - 6).values.astype(float).mean(),axis=1)
jsdf['zzdfsum'] = jsdf.apply( lambda x :x[hjson[0]['date']].sort_values().head(len(hjson[0]['date']) - 6).values.astype(float).sum(),axis=1)
jsdf['zzdfmax'] = jsdf.apply( lambda x :x[hjson[0]['date']].sort_values().head(len(hjson[0]['date']) - 6).values.astype(float).max(),axis=1)
jsdf.sort_values('zzdf',inplace = True)
jsdf = jsdf.reset_index()
jsdf.index = range(jsdf.shape[0])