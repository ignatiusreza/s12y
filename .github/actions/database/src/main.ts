import * as core from '@actions/core';
import * as exec from '@actions/exec';

async function run() {
  try {
    const options = {
      cwd: './apps/s12y',
    };
    core.exportVariable('MIX_ENV', 'test');
    core.exportVariable('POSTGRES_HOST', 'postgres');
    core.exportVariable('POSTGRES_PORT', '5432');

    await exec.exec('mix', ['local.rebar', '--force'], options);
    await exec.exec('mix', ['local.hex', '--force'], options);
    await exec.exec('mix', ['deps.get'], options);
    await exec.exec('mix', ['ecto.setup'], options);
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();
